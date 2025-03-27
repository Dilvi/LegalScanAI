from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch
import json
import os

class DocumentClassifier:
    def __init__(self, model_path="backend_services/model_doc_type"):
        self.tokenizer = AutoTokenizer.from_pretrained(model_path)
        self.model = AutoModelForSequenceClassification.from_pretrained(model_path)
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.model.to(self.device)

        with open(os.path.join(model_path, "label_map.json"), "r", encoding="utf-8") as f:
            self.label_map = json.load(f)

    def classify(self, text: str) -> dict:
        inputs = self.tokenizer(text, return_tensors="pt", truncation=True, padding=True).to(self.device)
        outputs = self.model(**inputs)
        probs = torch.nn.functional.softmax(outputs.logits, dim=1)[0]
        label_id = torch.argmax(probs).item()
        label = self.label_map[str(label_id)]
        confidence = round(probs[label_id].item() * 100, 2)
        return {"label": label, "confidence": confidence}