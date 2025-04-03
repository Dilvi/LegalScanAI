import easyocr
import cv2
import os

class ImageProcessor:
    def __init__(self):
        # Инициализация OCR с поддержкой русского и английского языков
        self.reader = easyocr.Reader(['ru', 'en'], gpu=False)

    def process_image(self, image_path: str) -> str:
        try:
            # Чтение изображения с помощью OpenCV
            image = cv2.imread(image_path)

            # Проверка на успешное открытие изображения
            if image is None or image.size == 0:
                return "Ошибка: не удалось открыть изображение или изображение пустое."

            # Предобработка изображения
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

            # Изменение размера изображения, если оно слишком маленькое
            if gray.shape[0] < 50 or gray.shape[1] < 50:
                return "Ошибка: изображение слишком маленькое для распознавания."

            # Попробуем изменить размер только если изображение не пустое
            try:
                gray = cv2.resize(gray, (1024, 768))
            except Exception as e:
                return f"Ошибка при изменении размера: {str(e)}"

            # Сохранение предобработанного изображения (для отладки)
            processed_image_path = image_path.replace(".jpg", "_processed.jpg")
            cv2.imwrite(processed_image_path, gray)

            # Распознавание текста с использованием EasyOCR
            result = self.reader.readtext(processed_image_path, detail=0)

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
