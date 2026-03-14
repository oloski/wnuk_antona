#!/bin/bash

cd /home/anton || exit

echo "🛡️ Naprawa W.N.U.K. A. (Korekta dla Ubuntu Noble 24.04)..."

# 1. Tworzenie struktury
mkdir -p agents/{executor_a,executor_b,mentor,librarian}
mkdir -p shared_data/{common,brain_a,brain_b,mentor_logs,library,qdrant,avatars,ui}
mkdir -p dashboard/ui

# 2. Dockerfile dla Agenta D (Z poprawionymi nazwami paczek dla Ubuntu 24.04)
cat <<EOF > agents/librarian/Dockerfile
FROM nvcr.io/nvidia/deepstream:8.0-triton-arm-sbsa

WORKDIR /app

# Noble (24.04) używa libflac12 zamiast libflac8
RUN apt-get update && apt-get install -y --no-install-recommends \\
    ca-certificates \\
    gnupg \\
    ubuntu-keyring \\
    && apt-get update && apt-get install -y \\
    libflac12 \\
    libmp3lame0 \\
    libxvidcore4 \\
    ffmpeg \\
    python3-gi \\
    python3-gst-1.0 \\
    python3-pip \\
    && rm -rf /var/lib/apt/lists/*

RUN if [ -f /opt/nvidia/deepstream/deepstream/user_additional_install.sh ]; then \\
    sh /opt/nvidia/deepstream/deepstream/user_additional_install.sh; \\
    fi

RUN pip3 install --no-cache-dir redis qdrant-client playwright beautifulsoup4 feedparser opencv-python

COPY . .

CMD ["python3", "sensor_bridge.py"]
EOF

# 3. Dockerfile dla Agentów A, B i C (Nemotron / Llama)
cat <<EOF > agents/executor_a/Dockerfile
FROM nvcr.io/nvidia/pytorch:24.01-py3
WORKDIR /app
RUN pip install --no-cache-dir redis qdrant-client
COPY . .
CMD ["python", "worker.py"]
EOF

cp agents/executor_a/Dockerfile agents/executor_b/Dockerfile
cp agents/executor_a/Dockerfile agents/mentor/Dockerfile

# 4. Docker-Compose
cat <<EOF > docker-compose.yml
version: '3.9'

services:
  redis:
    image: redis:7.2-alpine
    container_name: wnuk_redis
    networks: [wnuk_net]

  qdrant:
    image: qdrant/qdrant:latest
    container_name: wnuk_qdrant
    volumes: ['./shared_data/qdrant:/qdrant/storage']
    deploy:
      resources:
        reservations:
          devices: [{driver: nvidia, count: 1, capabilities: [gpu]}]
    networks: [wnuk_net]

  agent_a:
    build: ./agents/executor_a
    container_name: wnuk_executor_a
    depends_on: [redis, qdrant]
    environment:
      - ROLE=EXECUTOR_A
      - REDIS_URL=redis://redis:6379
    deploy:
      resources:
        reservations:
          devices: [{driver: nvidia, device_ids: ['0'], capabilities: [gpu]}]
    networks: [wnuk_net]

  agent_b:
    build: ./agents/executor_b
    container_name: wnuk_executor_b
    depends_on: [redis, qdrant]
    environment:
      - ROLE=EXECUTOR_B
      - REDIS_URL=redis://redis:6379
    deploy:
      resources:
        reservations:
          devices: [{driver: nvidia, device_ids: ['0'], capabilities: [gpu]}]
    networks: [wnuk_net]

  agent_c:
    build: ./agents/mentor
    container_name: wnuk_mentor_c
    environment:
      - ROLE=MENTOR
    deploy:
      resources:
        reservations:
          devices: [{driver: nvidia, device_ids: ['0'], capabilities: [gpu]}]
    networks: [wnuk_net]

  agent_d:
    build: ./agents/librarian
    container_name: wnuk_librarian_d
    privileged: true
    environment:
      - ROLE=LIBRARIAN
    volumes:
      - /dev/video0:/dev/video0
      - /tmp/.X11-unix:/tmp/.X11-unix
      - ./shared_data/common:/app/shared
    deploy:
      resources:
        reservations:
          devices: [{driver: nvidia, device_ids: ['0'], capabilities: [gpu, video]}]
    networks: [wnuk_net]

  dashboard:
    image: nginx:alpine
    container_name: wnuk_architect_ui
    ports: ["8080:80"]
    volumes: ['./shared_data/ui:/usr/share/nginx/html']
    networks: [wnuk_net]

networks:
  wnuk_net:
    driver: bridge
EOF

# 5. Tworzenie szkieletów plików Pythona
touch agents/executor_a/worker.py
touch agents/executor_b/worker.py
touch agents/mentor/judge.py
touch agents/librarian/sensor_bridge.py

# 6. Testowy Dashboard
cat <<EOF > shared_data/ui/index.html
<!DOCTYPE html>
<html>
<head><title>W.N.U.K. A. Dashboard</title><meta charset="utf-8"></head>
<body style="background:#050505; color:#00ff41; font-family:monospace; padding:50px;">
    <h1>SYSTEM W.N.U.K. A. :: STATUS ONLINE</h1>
    <hr color="#00ff41">
    <p>> Architektura: NVIDIA Grace Blackwell (GB10)</p>
    <p>> Agenci: A, B, C, D</p>
    <p>> Baza: Ubuntu 24.04 Noble</p>
</body>
</html>
EOF

chmod -R 777 /home/anton/shared_data

echo "✅ Projekt naprawiony pod Ubuntu Noble."
echo "🚀 Uruchom: docker compose up --build -d"
