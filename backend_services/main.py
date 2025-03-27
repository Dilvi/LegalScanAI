from fastapi import FastAPI
from pydantic import BaseModel
from document_classifier import DocumentClassifier

app = FastAPI()

classifier = DocumentClassifier()

class TextInput(BaseModel):
    text: str

@app.post("/classify")
async def classify_text(input: TextInput):
    result = classifier.classify(input.text)
    return {
        "result": f"📝 Тип документа: {result['label']} (уверенность: {result['confidence']}%)"
    }
