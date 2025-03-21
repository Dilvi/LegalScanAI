from fastapi import FastAPI
from transformers import AutoTokenizer, AutoModelForSequenceClassification

app = FastAPI()

MODEL_NAME = "nlpaueb/legal-bert-base-uncased"
tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
model = AutoModelForSequenceClassification.from_pretrained(MODEL_NAME)

@app.post("/predict")
async def predict(text: str):
    inputs = tokenizer(text, return_tensors="pt", truncation=True, padding=True)
    outputs = model(**inputs)
    # Process outputs (e.g., extract probabilities or labels)
    # Example response (replace with actual model logic):
    return {
        "result": "Legal analysis completed",
        "classification": "Contract",
        "confidence": 0.95
    }