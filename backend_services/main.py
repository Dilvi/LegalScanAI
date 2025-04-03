from fastapi import FastAPI
from pydantic import BaseModel
from document_classifier import DocumentClassifier
from ner_extractor import NERExtractor
from anonymizer import Anonymizer
from llm_connector import LLMConnector

app = FastAPI()

classifier = DocumentClassifier()
ner_extractor = NERExtractor()
anonymizer = Anonymizer()
llm_connector = LLMConnector()

class TextInput(BaseModel):
    text: str

@app.post("/analyze")
async def analyze_text(input: TextInput):
    # Классификация документа
    result = classifier.classify(input.text)
    classification_result = f"📝 Тип документа: {result['label']} (уверенность: {result['confidence']}%)"
    doc_type = result['label']  # Получаем тип документа

    # Извлечение сущностей
    entities = ner_extractor.extract_entities(input.text)
    if entities:
        entities_text = "\n\n🔍 Обнаруженные сущности:\n"
        for ent in entities:
            entities_text += f"🔹 [{ent['type']}] {ent['text']}\n"
    else:
        entities_text = "\n\n🔸 Сущности не обнаружены."

    # Обезличивание текста
    anonymized_text = anonymizer.anonymize(input.text, entities)
    anonymized_text_block = f"\n\n🔒 Обезличенный текст:\n{anonymized_text}"

    # Получение рекомендации от GPT-4o-mini
    recommendation = llm_connector.get_recommendation(anonymized_text, doc_type, entities)
    recommendation_block = f"\n\n💬 Рекомендация от GPT-4o-mini:\n{recommendation}"

    # Формируем полный результат
    full_result = classification_result + entities_text + anonymized_text_block + recommendation_block
    return {"result": full_result}
