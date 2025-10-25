import re

class TextFormatter:
    """
    Преобразует Markdown-подобный текст от GigaChat в чистый HTML для Flutter.
    """

    def format_text(self, text: str) -> str:
        text = text.strip()

        # Жирный текст
        text = re.sub(r"\*\*(.*?)\*\*", r"<b>\1</b>", text)

        # Заголовки
        text = re.sub(r"###\s*(.*?)\s*(?=\n|$)", r"<h2>\1</h2>", text)
        text = re.sub(r"##\s*(.*?)\s*(?=\n|$)", r"<h3>\1</h3>", text)

        # Горизонтальная линия
        text = re.sub(r"\s*---\s*", r"<hr>", text)

        # Маркированные списки
        text = re.sub(r"^- (.*?)$", r"• \1", text, flags=re.MULTILINE)

        # Нумерованные списки
        text = re.sub(r"^(\d+)\. (.*?)$", r"\1) \2", text, flags=re.MULTILINE)

        # Цитаты
        text = re.sub(r"^> (.*?)$", r"<i>\1</i>", text, flags=re.MULTILINE)

        # Код
        text = re.sub(r"`([^`]*)`", r"<code>\1</code>", text)

        # Переводы строк
        text = text.replace('\n', '<br>')

        # Убираем лишние <br>
        text = re.sub(r'(<h2>|<h3>|<hr>)(<br>)+', r'\1', text)
        text = re.sub(r'(<br>)+(<h2>|<h3>|<hr>)', r'\2', text)

        return text
