import os
import requests
import base64
import json

YANDEX_API_KEY = "AQVN2hxaq5quIiA3JC39hyEOj9clgKoUB_lxXti_"

class ImageProcessor:
    def __init__(self):
        self.api_key = YANDEX_API_KEY

    def encode_image(self, image_path):
        """Кодирует изображение в Base64."""
        with open(image_path, "rb") as image_file:
            return base64.b64encode(image_file.read()).decode("utf-8")

    def process_image(self, image_path: str) -> str:
        """Отправляет изображение в Yandex Vision OCR и возвращает распознанный текст."""
        try:
            if not os.path.exists(image_path):
                return "Ошибка: изображение не найдено."

            encoded = self.encode_image(image_path)

            data = {
                "mimeType": "image/jpeg",  # Можно изменить, если используете другие форматы
                "languageCodes": ["ru", "en"],
                "model": "page",
                "content": encoded,
            }

            headers = {
                "Content-Type": "application/json",
                "Authorization": f"Api-Key {self.api_key}",
            }

            url = "https://ocr.api.cloud.yandex.net/ocr/v1/recognizeText"
            response = requests.post(url=url, headers=headers, data=json.dumps(data))

            if response.status_code == 200:
                result_json = response.json()
                full_text = result_json.get("result", {}).get("textAnnotation", {}).get("fullText", "")
                return full_text.strip() if full_text else "Текст не распознан."
            else:
                return f"Ошибка от Yandex OCR API: {response.status_code} — {response.text}"

        except Exception as e:
            return f"Ошибка при обработке изображения: {str(e)}"

    def save_image(self, file, filename: str) -> str:
        save_path = f"./uploads/{filename}"
        try:
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
