import easyocr
from PIL import Image
import os

class ImageProcessor:
    def __init__(self):
        # Инициализация OCR с поддержкой русского языка
        self.reader = easyocr.Reader(['ru', 'en'], gpu=False)

    def process_image(self, image_path: str) -> str:
        try:
            # Чтение изображения
            result = self.reader.readtext(image_path, detail=0)
            # Объединение текста в одну строку
            extracted_text = " ".join(result)
            return extracted_text
        except Exception as e:
            return f"Ошибка при распознавании: {str(e)}"

    def save_image(self, file, filename: str) -> str:
        save_path = f"./uploads/{filename}"
        try:
            # Сохранение изображения на сервере
            file.save(save_path)
            return save_path
        except Exception as e:
            return f"Ошибка сохранения изображения: {str(e)}"

    def delete_image(self, path: str):
        try:
            if os.path.exists(path):
                os.remove(path)
        except Exception as e:
            print(f"Ошибка удаления файла: {str(e)}")
