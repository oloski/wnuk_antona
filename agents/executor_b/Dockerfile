FROM nvcr.io/nvidia/pytorch:24.01-py3
WORKDIR /app
RUN pip install --no-cache-dir redis qdrant-client
COPY . .
CMD ["python", "worker.py"]
