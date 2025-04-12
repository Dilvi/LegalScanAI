import re

class Anonymizer:
    def __init__(self):
        pass

    def anonymize(self, text: str, entities: list):
        """
        Заменяет личные данные в тексте на уникальные метки (например: [[PER_1]], [[ADDRESS_2]]).
        """
        anonymized_text = text
        # Сортировка по длине текста, чтобы избежать перекрытий
        entities = sorted(entities, key=lambda x: len(x['text']), reverse=True)

        for entity in entities:
            placeholder = f"[[{entity['label']}]]"
            # Безопасная замена (например, чтобы не заменить одно и то же несколько раз)
            anonymized_text = re.sub(re.escape(entity['text']), placeholder, anonymized_text)

        return anonymized_text
