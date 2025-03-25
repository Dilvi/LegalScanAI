from fastapi import FastAPI
from pydantic import BaseModel
from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch

app = FastAPI()

# Загружаем модель
model_name = "cointegrated/rubert-tiny-toxicity"  # Временно, заменим позже на Legal-BERT, натренированный для юридической оценки
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForSequenceClassification.from_pretrained(model_name)

class TextInput(BaseModel):
    text: str

@app.post("/analyze")
async def analyze_text(input: TextInput):
    try:
        inputs = tokenizer(input.text, return_tensors="pt", truncation=True, max_length=512)
        with torch.no_grad():
            outputs = model(**inputs)
            scores = torch.nn.functional.softmax(outputs.logits, dim=1).squeeze()

        # Симулируем "оценку риска" — тут можно подключить твою кастомную Legal-BERT модель позже
        risk_score = round(scores[1].item() * 100, 2)  # 0–100%
        is_safe = risk_score < 30

        if risk_score >= 70:
            risk_level = "высокий"
            recommendation = "Обратите внимание на формулировки, касающиеся штрафов и обязательств."
        elif risk_score >= 40:
            risk_level = "средний"
            recommendation = "Рекомендуется дополнительная проверка специалистом."
        else:
            risk_level = "низкий"
            recommendation = "Текст выглядит безопасным, но всё равно внимательно прочтите перед подписанием."

        result = (
            f"⚠️ Юридический риск: {risk_level} ({risk_score}%)\n"
            f"🛡️ Безопасность для подписания: {'высокая' if is_safe else 'низкая'}\n"
            f"💬 Рекомендация: {recommendation}"
        )

        return {"result": result}

    except Exception as e:
        return {"error": str(e)}
