class Anonymizer:
    def __init__(self):
        pass

    def anonymize(self, text: str, entities: list):
        """
        Заменяет личные данные в тексте на метки.
        """
        anonymized_text = text
        entities = sorted(entities, key=lambda x: len(x['text']), reverse=True)

        for entity in entities:
            placeholder = f"[[{entity['type']}]]"
            anonymized_text = anonymized_text.replace(entity['text'], placeholder)

        return anonymized_text
