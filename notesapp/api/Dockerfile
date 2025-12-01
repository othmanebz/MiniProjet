FROM python:3.11-slim

WORKDIR /app

# Dépendances système minimales
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

ENV FLASK_APP=app.py
ENV PYTHONUNBUFFERED=1

EXPOSE 5000

CMD ["python", "app.py"]
