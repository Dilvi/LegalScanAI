import spacy
import re
from collections import defaultdict

class NERExtractor:
    def __init__(self):
        self.nlp = spacy.load("ru_core_news_lg")

    def extract_entities(self, text: str):
        doc = self.nlp(text)
        entities_raw = []

        # spaCy-сущности
        for ent in doc.ents:
            entities_raw.append(("LOC" if ent.label_ == "LOC" else ent.label_, ent.text.strip()))

        # Паспорт
        passport_pattern = r"(серия\s*\d{4})[\s:,]*\s*(номер\s*\d{6})"
        passports = re.findall(passport_pattern, text, re.IGNORECASE)
        for match in passports:
            entities_raw.append(("PASSPORT", " ".join(match)))

        # Телефоны
        phone_pattern = r"((\+7|8)[-\s]?\(?\d{3}\)?[-\s]?\d{3}[-\s]?\d{2}[-\s]?\d{2})"
        phones = re.findall(phone_pattern, text)
        for match in phones:
            entities_raw.append(("PHONE", match[0]))

        # Адреса
        full_address_pattern = r"(?:город|г\.)\s*([А-ЯЁ][а-яё\-]*(?:[\s\-][А-ЯЁ][а-яё\-]*)?)[\s:,]*(?:улица|ул\.)\s*([А-ЯЁ][а-яё\-]*(?:[\s\-][А-ЯЁ][а-яё\-]*)?)[\s:,]*(?:дом|д\.)\s*(\d+)?"
        full_addresses = re.findall(full_address_pattern, text, re.IGNORECASE)
        for city, street, house in full_addresses:
            formatted = f"г. {city}, ул. {street}, д. {house}"
            entities_raw.append(("ADDRESS", formatted))

        # Деньги
        money_pattern = r"(?:(\d+(?:\s+\d+)*)|([А-ЯЁ][а-яё]*(?:\s+[А-ЯЁ][а-яё]*)*))\s*(тысяч|миллионов)?\s*(рублей|р\.|руб\.)"
        money_matches = re.findall(money_pattern, text, re.IGNORECASE)
        for number, word, unit, currency in money_matches:
            if number:
                formatted = f"{number} {unit or ''} {currency}"
            elif word:
                formatted = f"{word} {unit or ''} {currency}"
            entities_raw.append(("MONEY", re.sub(r"\s+", " ", formatted.strip())))

        # ФИО
        per_pattern_full = r"[А-ЯЁ][а-яё]+\s+[А-ЯЁ][а-яё]+\s+[А-ЯЁ][а-яё]+"
        per_matches = re.findall(per_pattern_full, text)
        for name in per_matches:
            entities_raw.append(("PER", name))

        # Длительность
        duration_pattern = r"(?:(\d+)|([а-яёА-ЯЁ]+(?:\s+[а-яёА-ЯЁ]*)*))\s*(года?|лет|месяцев?|недел(?:ь|и)|дн(?:ей|я)|месяц(?:а|ев)?)"
        duration_matches = re.findall(duration_pattern, text, re.IGNORECASE)
        for number, word, unit in duration_matches:
            if number:
                formatted = f"{number} {unit}"
            elif word:
                formatted = f"{word} {unit}"
            else:
                continue
            entities_raw.append(("DURATION", formatted.strip()))

        # Удаление дубликатов и нумерация
        seen = defaultdict(set)
        counter = defaultdict(int)
        final_entities = []

        for type_, value in entities_raw:
            value = value.strip()
            if value.lower() in seen[type_]:
                continue
            seen[type_].add(value.lower())
            counter[type_] += 1
            label = f"{type_}_{counter[type_]}" if counter[type_] > 1 else type_
            final_entities.append({
                "type": type_,
                "label": label,
                "text": value
            })

        return final_entities
