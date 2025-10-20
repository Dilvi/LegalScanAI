from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch
import json
from pathlib import Path

class DocumentClassifier:
    def __init__(self):
        # Абсолютный путь к директории модели
        base_dir = Path(__file__).resolve().parent
        model_path = base_dir / "model_doc_type"

        # Загружаем токенизатор и модель (автоматически подхватит model.safetensors)
        self.tokenizer = AutoTokenizer.from_pretrained(str(model_path))
        self.model = AutoModelForSequenceClassification.from_pretrained(str(model_path))

        # Устройство
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.model.to(self.device)

        # Загружаем карту меток
        label_map_path = model_path / "label_map.json"
        with open(label_map_path, "r", encoding="utf-8") as f:
            self.label_map = json.load(f)

    def classify(self, text: str) -> dict:
        # Подготовка текста
        inputs = self.tokenizer(text, return_tensors="pt", truncation=True, padding=True).to(self.device)
        outputs = self.model(**inputs)

        # Вычисляем вероятности и выбираем метку
        probs = torch.nn.functional.softmax(outputs.logits, dim=1)[0]
        label_id = torch.argmax(probs).item()
        label = self.label_map[str(label_id)]
        confidence = round(probs[label_id].item() * 100, 2)

        return {
            "label": label,
            "confidence": confidence
        }
