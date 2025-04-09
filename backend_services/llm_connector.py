import g4f
from text_formatter import TextFormatter
import re

class LLMConnector:
    def __init__(self):
        self.client = g4f.Client()
        self.formatter = TextFormatter()

    def clean_output(self, response: str) -> str:
        """
        Удаляет обезличенные сущности ([LOC], [ORG], [PER]) из ответа нейросети.
        """
        # Удаляем любые упоминания вида [[...]]
        return re.sub(r"\[\[(.*?)\]\]", "", response).strip()

    def get_recommendation(self, text: str, doc_type: str = "Неизвестный документ", entities: list = [], confidence: float = 100.0) -> str:
        try:
            # Если уверенность в определении типа документа ниже 50%, просим нейросеть определить его
            if confidence < 50 or not doc_type:
                doc_type = "Неизвестный документ"

            # Формируем строку с сущностями, если они есть
            entities_summary = ", ".join([f"{ent['type']}: {ent['text']}" for ent in entities]) if entities else "Отсутствуют"

            prompt = (
                f"Вы являетесь юридическим помощником, предоставляющим рекомендации строго на основе действующего законодательства России. "
                f"Ваша задача — проанализировать предоставленный обезличенный документ и выявить юридические риски или потенциальные проблемы, которые могут возникнуть при его подписании или использовании. "
                f"Ответ должен начинаться с 'true' или 'false' в зависимости от наличия юридических рисков, а затем следовать подробный анализ."
                f"Документ может содержать обезличенные данные (например, [[PER]], [[ORG]], [[LOC]] и т.д.), на них не нужно обращать внимание, так как они представляют собой обезличенные данные. "
                f"Если в документе присутствуют риски, укажите их и дайте ссылки на соответствующие статьи законов. "
                f"Если рисков нет, укажите формулировки, которые могут вызвать недопонимание или потребовать уточнения. "
                f"Избегайте общих фраз и предоставляйте рекомендации строго по документу, выделяя конкретные юридические аспекты.\n\n"
                f"Тип документа: {doc_type} (уверенность определения: {confidence}%)\n"
                f"Ключевые сущности (могут быть обезличены): {entities_summary}\n"
                f"Текст документа (обезличенный): {text}\n\n"
            )

            # Синхронный вызов модели gpt-4o-mini через g4f
            response = g4f.ChatCompletion.create(
                model="gpt-4o-mini",
                messages=[{"role": "user", "content": prompt}],
                stream=False
            )

            # Проверяем наличие ответа
            if response and isinstance(response, str):
                cleaned_response = self.clean_output(response.strip())

                # Извлекаем флаг риска из начала строки
                has_risk = cleaned_response.lower().startswith("true")
                self.has_risk = has_risk

                # Удаляем флаг из текста перед отображением
                formatted_response = cleaned_response[4:].strip() if has_risk else cleaned_response[5:].strip()
                formatted_response = self.formatter.format_text(formatted_response)

                return formatted_response
            else:
                self.has_risk = False
                return "Ошибка: Пустой или некорректный ответ от модели."
        except Exception as e:
            self.has_risk = False
            return f"Ошибка генерации рекомендации: {str(e)}"

    def get_risk_flag(self) -> bool:
        """Метод для получения значения флага риска."""
        return getattr(self, 'has_risk', False)
