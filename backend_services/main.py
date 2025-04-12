from fastapi import FastAPI, UploadFile, File
from pydantic import BaseModel
from document_classifier import DocumentClassifier
from ner_extractor import NERExtractor
from anonymizer import Anonymizer
from llm_connector import LLMConnector
from image_processor import ImageProcessor
from chat_service import LegalMindChat

app = FastAPI()

classifier = DocumentClassifier()
ner_extractor = NERExtractor()
anonymizer = Anonymizer()
llm_connector = LLMConnector()
image_processor = ImageProcessor()

class TextInput(BaseModel):
    text: str

@app.post("/analyze")
async def analyze_text(input: TextInput):
    # Классификация документа
    result = classifier.classify(input.text)
    classification_result = f"📝 Тип документа: {result['label']} (уверенность: {result['confidence']}%)"
    doc_type = result['label']

    # Извлечение сущностей
    entities = ner_extractor.extract_entities(input.text)
    if entities:
        entities_text = "\n\n🔍 Обнаруженные сущности:\n"
        for ent in entities:
            entities_text += f"🔹 [{ent['label']}] {ent['text']}\n"
    else:
        entities_text = "\n\n🔸 Сущности не обнаружены."


    # Обезличивание текста
    anonymized_text = anonymizer.anonymize(input.text, entities)
    anonymized_text_block = f"\n\n🔒 Обезличенный текст:\n{anonymized_text}"

    # Получение рекомендации
    recommendation = llm_connector.get_recommendation(anonymized_text, doc_type, entities)
    recommendation_block = f"\n\n💬 Рекомендация от LegalScanAI:\n{recommendation}"

    full_result = classification_result + entities_text + anonymized_text_block + recommendation_block

    # ⬇️ Новое — флаг риска
    has_risk = llm_connector.get_risk_flag()

    return {
        "result": full_result,
        "has_risk": has_risk
    }


from fastapi.responses import JSONResponse

@app.post("/analyze-image")
async def analyze_image(file: UploadFile = File(...)):
    try:
        # Сохраняем изображение
        image_path = f"./uploads/{file.filename}"
        with open(image_path, "wb") as f:
            f.write(await file.read())

        # Обработка изображения
        text = image_processor.process_image(image_path)

        # Анализ текста
        result = await analyze_text(TextInput(text=text))

        # Удаляем изображение после обработки
        image_processor.delete_image(image_path)

        # Возвращаем результат с кодировкой UTF-8
        return JSONResponse(content={"result": result["result"]}, media_type="application/json; charset=utf-8")
    except Exception as e:
        return JSONResponse(content={"result": f"Ошибка: {str(e)}"}, media_type="application/json; charset=utf-8")

# Создаем экземпляр LegalMind
legal_mind = LegalMindChat()

class Message(BaseModel):
    text: str

@app.post("/chat")
async def chat(input: Message):
    try:
        response = legal_mind.get_response(input.text)
        return {"response": response}
    except Exception as e:
        return {"error": str(e)}