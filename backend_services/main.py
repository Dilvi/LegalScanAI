from fastapi import FastAPI, UploadFile, File, Form
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import Optional

from backend_services.llm_connector import LLMConnector
from backend_services.image_processor import ImageProcessor
from backend_services.chat_service import LegalMindChat
from backend_services.text_formatter import TextFormatter  # ✅

app = FastAPI()

# 🧠 Сервисы
llm_connector = LLMConnector()
image_processor = ImageProcessor()
legal_mind = LegalMindChat()
formatter = TextFormatter()  # ✅


class TextInput(BaseModel):
    text: str
    docType: Optional[str] = None


@app.post("/analyze")
async def analyze_text(input: TextInput):
    """
    Анализ текста без анонимизации:
    - docType приходит с клиента,
    - отправляем в GigaChat,
    - форматируем текст перед отправкой клиенту.
    """
    used_doc_type = input.docType or "unknown"

    # 1. Получаем текст
    recommendation = llm_connector.get_recommendation(
        text=input.text,
        doc_type=used_doc_type,
        entities=[],
    )
    has_risk = llm_connector.get_risk_flag()

    # 2. Форматируем
    formatted_html = formatter.format_text(recommendation)

    # 3. Возвращаем готовый HTML
    return {
        "result": formatted_html,
        "has_risk": has_risk
    }


@app.post("/analyze-image")
async def analyze_image(
        file: UploadFile = File(...),
        docType: Optional[str] = Form(None),
):
    """
    Анализ изображения:
    - OCR -> GigaChat -> форматирование
    """
    try:
        image_path = f"./uploads/{file.filename}"
        with open(image_path, "wb") as f:
            f.write(await file.read())

        text = image_processor.process_image(image_path)
        used_doc_type = docType or "unknown"

        recommendation = llm_connector.get_recommendation(
            text=text,
            doc_type=used_doc_type,
            entities=[],
        )
        has_risk = llm_connector.get_risk_flag()

        formatted_html = formatter.format_text(recommendation)

        image_processor.delete_image(image_path)

        return JSONResponse(
            content={"result": formatted_html, "has_risk": has_risk},
            media_type="application/json; charset=utf-8"
        )
    except Exception as e:
        return JSONResponse(
            content={"result": f"Ошибка: {str(e)}"},
            media_type="application/json; charset=utf-8"
        )


class Message(BaseModel):
    text: str


@app.post("/chat")
async def chat(input: Message):
    """
    Чат с LegalMind.
    """
    try:
        response = legal_mind.get_response(input.text)
        return {"response": response}
    except Exception as e:
        return {"error": str(e)}
