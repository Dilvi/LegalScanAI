import re

class TextFormatter:
    def format_text(self, text: str) -> str:
        # Жирный текст (например, **такой**)
        text = re.sub(r"\*\*(.*?)\*\*", r"<b>\1</b>", text)

        # Заголовки (например, ###Такое)
        text = re.sub(r"###\s*(.*?)\n", r"<h2>\1</h2>\n", text)

        # Подзаголовки (например, ##Такое)
        text = re.sub(r"##\s*(.*?)\n", r"<h3>\1</h3>\n", text)

        # Маркированные списки (например, - Пункт)
        text = re.sub(r"^- (.*?)$", r"• \1", text, flags=re.MULTILINE)

        # Нумерованные списки (например, 1. Пункт)
        text = re.sub(r"^(\d+)\. (.*?)$", r"\1) \2", text, flags=re.MULTILINE)

        # Цитаты (например, > Цитата)
        text = re.sub(r"^> (.*?)$", r"<i>\1</i>", text, flags=re.MULTILINE)

        # Код (например, `код`)
        text = re.sub(r"`([^`]*)`", r"<code>\1</code>", text)

        return text
