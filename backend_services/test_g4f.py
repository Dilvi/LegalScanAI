from g4f.client import Client

client = Client()
response = client.chat.completions.create(
    model="gpt-4o-mini",
    messages=[{"role": "user", "content": "Привет! Дай совет по договору аренды."}],
    web_search=False
)
print(response.choices[0].message.content)
