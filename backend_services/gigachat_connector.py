# backend_services/gigachat_connector.py
import os
import time
import uuid
import requests

GIGACHAT_AUTH_URL = "https://ngw.devices.sberbank.ru:9443/api/v2/oauth"
GIGACHAT_API_URL = "https://gigachat.devices.sberbank.ru/api/v1/chat/completions"


class GigaChatConnector:
    def __init__(self, cert_path: str = None):
        self.auth_key = os.getenv("GIGACHAT_AUTH_KEY")
        if not self.auth_key:
            raise ValueError("❌ Переменная окружения GIGACHAT_AUTH_KEY не найдена")

        self.cert_path = cert_path or os.getenv("GIGACHAT_CERT_PATH", "").strip() or True
        self.access_token = None
        self.token_expires_at = 0

    def _refresh_token(self):
        headers = {
            "Content-Type": "application/x-www-form-urlencoded",
            "Accept": "application/json",
            "RqUID": str(uuid.uuid4()),
            "Authorization": f"Basic {self.auth_key}"  # ✅ Исправлено
        }
        data = {"scope": "GIGACHAT_API_PERS"}

        response = requests.post(GIGACHAT_AUTH_URL, headers=headers, data=data, verify=self.cert_path)
        if response.status_code != 200:
            raise Exception(f"Ошибка получения токена: {response.status_code} {response.text}")

        token_data = response.json()
        self.access_token = token_data["access_token"]
        self.token_expires_at = time.time() + int(token_data.get("expires_in", 1500))
        print("✅ GigaChat access token обновлён")

    def _get_token(self):
        if not self.access_token or time.time() > self.token_expires_at:
            self._refresh_token()
        return self.access_token

    def ask(self, prompt: str, temperature: float = 0.3, max_tokens: int = 2000) -> str:
        token = self._get_token()
        headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
            "Accept": "application/json",
        }
        payload = {
            "model": "GigaChat",
            "messages": [{"role": "user", "content": prompt}],
            "temperature": temperature,
            "max_tokens": max_tokens
        }

        response = requests.post(GIGACHAT_API_URL, headers=headers, json=payload, verify=self.cert_path)
        if response.status_code != 200:
            raise Exception(f"Ошибка GigaChat: {response.status_code} {response.text}")

        data = response.json()
        try:
            return data["choices"][0]["message"]["content"]
        except (KeyError, IndexError):
            raise Exception(f"Непредвиденный ответ GigaChat: {data}")
