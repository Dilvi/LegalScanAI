import re
import yaml
from pathlib import Path
from collections import defaultdict

# spaCy используется как fallback
try:
    import spacy
    _spacy_model = spacy.load("ru_core_news_lg")
except Exception:
    _spacy_model = None


class Anonymizer:
    """
    Единый модуль анонимизации текста по типу документа.
    1) Загружает YAML с паттернами для данного doc_type.
    2) Извлекает сущности через regex.
    3) Дополняет spaCy при необходимости.
    4) Заменяет найденные значения на маркеры [[LABEL]].
    """

    def __init__(self, doc_type: str):
        self.doc_type = doc_type
        self.rules = self._load_rules(doc_type)
        self.use_spacy = _spacy_model is not None

        # Минимальная длина сущности для замены
        self.min_entity_length = 3

        # Стоп-слова, которые не должны маркироваться как PER
        self.stoplist_per = {
            "продавец", "покупатель", "договор", "настоящий", "ТС",
            "автомобиль", "деньги", "передал", "получил", "подпись", "ФИО"
        }

    # ------------------------------------------------------------
    def _load_rules(self, doc_type: str) -> dict:
        """Загружает YAML-файл с правилами для данного типа документа"""
        base_dir = Path(__file__).resolve().parent
        rules_path = base_dir / "anonymizer_rules" / f"{doc_type}.yaml"
        if not rules_path.exists():
            return {}
        with open(rules_path, "r", encoding="utf-8") as f:
            return yaml.safe_load(f)

    # ------------------------------------------------------------
    def extract_entities(self, text: str):
        """
        Извлекает сущности на основе правил + опционально spaCy.
        Возвращает список словарей вида:
        {"type": "PER", "label": "PER_1", "text": "Иванов Иван Иванович"}
        """
        entities_raw = []

        # 1. Правила из YAML
        if self.rules and "patterns" in self.rules:
            for entry in self.rules["patterns"]:
                ent_type = entry["type"]
                for pattern in entry["regex"]:
                    matches = re.findall(pattern, text, re.IGNORECASE)
                    for match in matches:
                        if isinstance(match, tuple):
                            match = " ".join(match).strip()
                        match = match.strip()
                        if len(match) < self.min_entity_length:
                            continue
                        # фильтрация PER по стоп-листу
                        if ent_type == "PER" and match.lower() in self.stoplist_per:
                            continue
                        entities_raw.append((ent_type, match))

        # 2. fallback — spaCy (если включен и не отключён в YAML)
        if self.use_spacy and self.rules.get("enable_spacy_fallback", True):
            doc = _spacy_model(text)
            for ent in doc.ents:
                ent_type = self._map_spacy_label(ent.label_)
                if not ent_type:
                    continue
                match = ent.text.strip()
                if len(match) < self.min_entity_length:
                    continue
                if ent_type == "PER" and match.lower() in self.stoplist_per:
                    continue
                entities_raw.append((ent_type, match))

        # 3. Удаление дубликатов и нумерация
        seen = defaultdict(set)
        counter = defaultdict(int)
        final_entities = []

        for ent_type, ent_text in sorted(entities_raw, key=lambda x: len(x[1]), reverse=True):
            norm = ent_text.lower()
            if norm in seen[ent_type]:
                continue
            seen[ent_type].add(norm)
            counter[ent_type] += 1
            label = f"{ent_type}_{counter[ent_type]}" if counter[ent_type] > 1 else ent_type
            final_entities.append({
                "type": ent_type,
                "label": label,
                "text": ent_text
            })

        return final_entities

    # ------------------------------------------------------------
    def anonymize(self, text: str, entities: list):
        """Заменяет найденные сущности на [[LABEL]]"""
        anonymized_text = text
        # сортируем по длине, чтобы не ломать вложенные сущности
        entities_sorted = sorted(entities, key=lambda e: len(e['text']), reverse=True)
        for entity in entities_sorted:
            if len(entity['text']) < self.min_entity_length:
                continue
            # добавляем границы слова, чтобы не ломать части слов
            anonymized_text = re.sub(
                r'\b' + re.escape(entity['text']) + r'\b',
                f"[[{entity['label']}]]",
                anonymized_text
            )
        return anonymized_text

    # ------------------------------------------------------------
    def run(self, text: str):
        """
        Полный цикл анонимизации:
        - извлечение сущностей
        - замена на маркеры
        - возврат анонимизированного текста и списка сущностей
        """
        entities = self.extract_entities(text)
        anonymized_text = self.anonymize(text, entities)
        return {
            "doc_type": self.doc_type,
            "anonymized_text": anonymized_text,
            "entities": entities
        }

    # ------------------------------------------------------------
    @staticmethod
    def _map_spacy_label(label: str) -> str:
        """Маппинг spaCy label → наши типы"""
        mapping = {
            "PER": "PER",
            "LOC": "ADDRESS",
            "ORG": "ORG",
            "MONEY": "MONEY",
            "DATE": "DATE",
        }
        return mapping.get(label, None)
