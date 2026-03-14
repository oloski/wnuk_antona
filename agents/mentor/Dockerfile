FROM nvcr.io/nvidia/pytorch:24.01-py3
WORKDIR /app
# Instalacja brakujacych bibliotek dla API
RUN pip install --no-cache-dir redis qdrant-client fastapi uvicorn
COPY . .
# POPRAWKA: Startujemy judge.py zamiast worker.py
CMD ["python3", "judge.py"]
