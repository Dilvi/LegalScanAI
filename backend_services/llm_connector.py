import g4f

class LLMConnector:
    def __init__(self):
        self.client = g4f.Client()

    def get_recommendation(self, text: str, doc_type: str, entities: list) -> str:
        try:
            # Формируем детализированный запрос с учётом типа документа и сущностей
            entities_summary = ", ".join([f"{ent['type']}: {ent['text']}" for ent in entities])
            prompt = (
                f"Документ: {doc_type}\n"
                f"Обнаруженные ключевые сущности: {entities_summary}\n"
                f"Текст документа (обезличенный): {text}\n\n"
                f"Дайте рекомендации по подписанию этого документа. "
                f"Укажите юридические риски и на что стоит обратить внимание."
            )

            # Синхронный вызов модели gpt-4o-mini через g4f
            response = g4f.ChatCompletion.create(
                model="gpt-4o-mini",
                messages=[{"role": "user", "content": prompt}],
                stream=False
            )

            # Проверяем наличие ответа
            if response and isinstance(response, str):
                return response.strip()
            else:
                return "Ошибка: Пустой или некорректный ответ от модели."
        except Exception as e:
            # Подробный вывод ошибки
            return f"Ошибка генерации рекомендации: {str(e)}"
