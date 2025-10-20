# backend_services/llm_connector.py
import os
import time
import uuid
import json
import re
import requests
from typing import List, Dict, Optional

# --- Фолбэк для форматтера ---
try:
    from text_formatter import TextFormatter
except Exception:
    class TextFormatter:
        def format_text(self, t: str) -> str:
            return t

# --- Константы GigaChat ---
GIGACHAT_OAUTH_URL = "https://ngw.devices.sberbank.ru:9443/api/v2/oauth"
GIGACHAT_API_BASE = "https://gigachat.devices.sberbank.ru/api/v1"


class GigaChatClient:
    """
    Клиент для GigaChat:
    - Получает и кэширует access_token на ~29 минут
    - Делает запросы к /chat/completions
    """

    def __init__(self,
                 authorization_key: Optional[str] = None,
                 scope: str = "GIGACHAT_API_PERS",
                 cert_path: Optional[str] = None,
                 timeout: int = 30):
        self.authorization_key = authorization_key or os.getenv("GIGACHAT_AUTH_KEY", "").strip()
        self.scope = scope

        # Если указан путь к сертификату — используем его, иначе системные корни
        self.cert_path = cert_path or os.getenv("GIGACHAT_CERT_PATH", "").strip() or True

        self.timeout = timeout
        self._token: Optional[str] = None
        self._token_expire_ts: float = 0.0

        if not self.authorization_key:
            raise RuntimeError(
                "❌ Не задан Authorization key для GigaChat. "
                "Установите переменную окружения GIGACHAT_AUTH_KEY или передайте authorization_key в конструктор."
            )

    def _need_refresh(self) -> bool:
        return not self._token or (time.time() >= self._token_expire_ts - 60)

    def get_access_token(self) -> str:
        """
        Получает и кэширует access token (TTL ~30 минут).
        """
        if not self._need_refresh():
            return self._token  # type: ignore

        headers = {
            "Content-Type": "application/x-www-form-urlencoded",
            "Accept": "application/json",
            "RqUID": str(uuid.uuid4()),
            "Authorization": f"Basic {self.authorization_key}",
        }
        data = {"scope": self.scope}

        resp = requests.post(
            GIGACHAT_OAUTH_URL,
            headers=headers,
            data=data,
            timeout=self.timeout,
            verify=self.cert_path,  # ✅ теперь используется реальный сертификат
        )
        resp.raise_for_status()
        payload = resp.json()
        access_token = payload.get("access_token")
        if not access_token:
            raise RuntimeError(f"OAuth ответ без access_token: {payload}")

        ttl = int(payload.get("expires_in", 1740))  # 29 минут по умолчанию
        self._token = access_token
        self._token_expire_ts = time.time() + ttl
        return access_token

    def chat_completions(self,
                         messages: List[Dict[str, str]],
                         model: str = "GigaChat",
                         temperature: float = 0.2,
                         max_tokens: int = 2000) -> str:
        token = self.get_access_token()
        url = f"{GIGACHAT_API_BASE}/chat/completions"
        headers = {
            "Accept": "application/json",
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
        }
        body = {
            "model": model,
            "messages": messages,
            "temperature": temperature,
            "max_tokens": max_tokens,
            "stream": False,
        }

        resp = requests.post(url, headers=headers, data=json.dumps(body), timeout=self.timeout, verify=self.cert_path)
        resp.raise_for_status()
        data = resp.json()

        try:
            return data["choices"][0]["message"]["content"]
        except (KeyError, IndexError):
            raise RuntimeError(f"Некорректный ответ от GigaChat: {data}")


class LLMConnector:
    """
    Обёртка вокруг GigaChat с нашим промптом и постпроцессингом.
    """

    def __init__(self,
                 authorization_key: Optional[str] = None,
                 scope: str = "GIGACHAT_API_PERS",
                 cert_path: Optional[str] = None):
        self.client = GigaChatClient(authorization_key=authorization_key, scope=scope, cert_path=cert_path)
        self.formatter = TextFormatter()
        self.has_risk: bool = False

    @staticmethod
    def _clean_double_brackets(text: str) -> str:
        return re.sub(r"\[\[(.*?)\]\]", "", text).strip()

    @staticmethod
    def _build_prompt(doc_type: str, entities_summary: str, text: str) -> str:
        return (
            "Вы являетесь опытным юридическим помощником, предоставляющим рекомендации строго на основе "
            "действующего законодательства Российской Федерации.\n\n"
            "Ваша задача — проанализировать предоставленный обезличенный договор и:\n"
            "1. Определить, содержит ли он критические юридические риски — положения, которые:\n"
            "   • могут привести к существенным финансовым или имущественным потерям,\n"
            "   • создают правовую неопределённость,\n"
            "   • противоречат действующему законодательству или ущемляют права сторон.\n"
            "2. В начале ответа строго вывести:\n"
            "   • true — если присутствуют критические риски;\n"
            "   • false — если критических рисков не выявлено.\n"
            "3. Затем:\n"
            "   • если есть критические риски — перечислить их с указанием пункта/формулировки, последствий и ссылки на закон;\n"
            "   • если есть только незначительные замечания — перечислить их отдельно;\n"
            "   • если рисков нет вовсе — так и указать.\n"
            "4. Игнорируйте обезличенные маркеры [[...]].\n\n"
            f"Тип документа: {doc_type}\n"
            f"Ключевые сущности: {entities_summary}\n"
            f"Текст документа (обезличенный):\n{text[:10000]}\n"
        )

    def get_recommendation(self,
                           text: str,
                           doc_type: str = "Неизвестный документ",
                           entities: Optional[List[Dict[str, str]]] = None,
                           confidence: float = 100.0) -> str:

        entities_summary = ", ".join([f"{e.get('type','?')}: {e.get('text','')}" for e in (entities or [])]) \
            if entities else "Отсутствуют"

        prompt = self._build_prompt(doc_type=doc_type, entities_summary=entities_summary, text=text)

        raw = self.client.chat_completions(
            messages=[{"role": "user", "content": prompt}],
            model="GigaChat",
            temperature=0.2,
            max_tokens=2000
        )

        cleaned = self._clean_double_brackets(raw)
        head = cleaned.strip().lower()

        risk_flag = None
        m = re.match(r"^\s*(true|false)\b", head)
        if m:
            risk_flag = (m.group(1) == "true")
            cleaned = cleaned[m.end():].lstrip()

        self.has_risk = bool(risk_flag)
        return self.formatter.format_text(cleaned)

    def get_risk_flag(self) -> bool:
        return bool(self.has_risk)
