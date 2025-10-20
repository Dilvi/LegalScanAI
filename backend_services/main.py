# backend_services/main.py
from fastapi import FastAPI, UploadFile, File, Form
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import Optional, Dict, Any

# ✅ Корректные импорты
from backend_services.anonymizer import Anonymizer
from backend_services.llm_connector import LLMConnector
from backend_services.image_processor import ImageProcessor
from backend_services.chat_service import LegalMindChat  # 👈 Оставляем только этот импорт

app = FastAPI()

# 🧠 Инициализация сервисов
llm_connector = LLMConnector()   # authorization_key берёт из env GIGACHAT_AUTH_KEY
image_processor = ImageProcessor()
legal_mind = LegalMindChat()


class TextInput(BaseModel):
    text: str
    docType: Optional[str] = None


def _anonymize(text: str, doc_type: Optional[str]) -> Dict[str, Any]:
    """
    Унифицированная анонимизация под заданный тип документа.
    Если doc_type не задан — используем общий профиль (или 'unknown').
    """
    dt = doc_type or "unknown"
    try:
        anonymizer = Anonymizer(doc_type=dt)
        result = anonymizer.run(text)  # {'doc_type','anonymized_text','entities'}
        return result
    except TypeError:
        # На случай, если у тебя ещё старый интерфейс Anonymizer
        return {"doc_type": dt, "anonymized_text": text, "entities": []}


@app.post("/analyze")
async def analyze_text(input: TextInput):
    """
    Анализ текста:
    - docType приходит с клиента (ручной выбор),
    - анонимизация в соответствии с типом,
    - отправка в GigaChat, разбор true/false,
    - возврат результата и флага.
    """
    anon = _anonymize(input.text, input.docType)
    anonymized_text = anon.get("anonymized_text", input.text)
    entities = anon.get("entities", [])
    used_doc_type = input.docType or anon.get("doc_type", "unknown")

    # Получаем рекомендацию от GigaChat
    recommendation = llm_connector.get_recommendation(
        text=anonymized_text,
        doc_type=used_doc_type,
        entities=entities,
    )
    has_risk = llm_connector.get_risk_flag()

    # Формируем финальный ответ
    entities_text = ""
    if entities:
        entities_text = "\n\n🔍 Обнаруженные сущности:\n" + "\n".join(
            f"🔹 [{e.get('label', e.get('type','?'))}] {e.get('text','')}" for e in entities
        )

    anonymized_block = f"\n\n🔒 Обезличенный текст:\n{anonymized_text}"
    recommendation_block = f"\n\n💬 Рекомендация от LegalScanAI:\n{recommendation}"
    full_result = f"📝 Тип документа: {used_doc_type}{entities_text}{anonymized_block}{recommendation_block}"

    return {
        "result": full_result,
        "has_risk": has_risk
    }


@app.post("/analyze-image")
async def analyze_image(
        file: UploadFile = File(...),
        docType: Optional[str] = Form(None),
):
    """
    Анализ изображения:
    - принимаем docType в multipart/form-data,
    - OCR -> анонимизация -> GigaChat
    """
    try:
        image_path = f"./uploads/{file.filename}"
        with open(image_path, "wb") as f:
            f.write(await file.read())

        text = image_processor.process_image(image_path)

        # Анонимизация и анализ
        anon = _anonymize(text, docType)
        anonymized_text = anon.get("anonymized_text", text)
        entities = anon.get("entities", [])
        used_doc_type = docType or anon.get("doc_type", "unknown")

        recommendation = llm_connector.get_recommendation(
            text=anonymized_text,
            doc_type=used_doc_type,
            entities=entities,
        )
        has_risk = llm_connector.get_risk_flag()

        image_processor.delete_image(image_path)

        entities_text = ""
        if entities:
            entities_text = "\n\n🔍 Обнаруженные сущности:\n" + "\n".join(
                f"🔹 [{e.get('label', e.get('type','?'))}] {e.get('text','')}" for e in entities
            )
        anonymized_block = f"\n\n🔒 Обезличенный текст:\n{anonymized_text}"
        recommendation_block = f"\n\n💬 Рекомендация от LegalScanAI:\n{recommendation}"
        full_result = f"📝 Тип документа: {used_doc_type}{entities_text}{anonymized_block}{recommendation_block}"

        return JSONResponse(
            content={"result": full_result, "has_risk": has_risk},
            media_type="application/json; charset=utf-8"
        )
    except Exception as e:
        return JSONResponse(content={"result": f"Ошибка: {str(e)}"}, media_type="application/json; charset=utf-8")


class Message(BaseModel):
    text: str


@app.post("/chat")
async def chat(input: Message):
    """
    Чат с LegalMind (если используется).
    """
    try:
        response = legal_mind.get_response(input.text)
        return {"response": response}
    except Exception as e:
        return {"error": str(e)}
