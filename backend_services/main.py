from fastapi import FastAPI
from pydantic import BaseModel
from document_classifier import DocumentClassifier

app = FastAPI()
classifier = DocumentClassifier()

class TextInput(BaseModel):
    text: str

class AnalyzeResult(BaseModel):
    result: str

@app.post("/classify", response_model=AnalyzeResult)
async def classify_text(input: TextInput):
    try:
        prediction = classifier.classify(input.text)
        result_text = (
            f"📄 Тип документа: {prediction['label']}\n"
            f"📊 Уверенность: {prediction['confidence']}%"
        )
        return {"result": result_text}
    except Exception as e:
        return {"result": f"Ошибка: {str(e)}"}