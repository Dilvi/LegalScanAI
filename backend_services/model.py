from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch

class LegalBertAnalyzer:
    def __init__(self):
        self.tokenizer = AutoTokenizer.from_pretrained("nlpaueb/legal-bert-base-uncased")
        self.model = AutoModelForSequenceClassification.from_pretrained("nlpaueb/legal-bert-base-uncased")

    def analyze_text(self, text: str) -> str:
        inputs = self.tokenizer(text, return_tensors="pt", truncation=True, padding=True)
        outputs = self.model(**inputs)
        logits = outputs.logits.detach().numpy()
        prediction = logits.argmax(axis=1)[0]
        return f"Результат классификации: {prediction}"