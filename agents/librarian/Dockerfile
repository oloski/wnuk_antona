FROM nvcr.io/nvidia/deepstream:8.0-triton-arm-sbsa

WORKDIR /app

# Noble (24.04) używa libflac12 zamiast libflac8
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    gnupg \
    ubuntu-keyring \
    && apt-get update && apt-get install -y \
    libflac12 \
    libmp3lame0 \
    libxvidcore4 \
    ffmpeg \
    python3-gi \
    python3-gst-1.0 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN if [ -f /opt/nvidia/deepstream/deepstream/user_additional_install.sh ]; then \
    sh /opt/nvidia/deepstream/deepstream/user_additional_install.sh; \
    fi

RUN pip3 install --no-cache-dir redis qdrant-client playwright beautifulsoup4 feedparser opencv-python

COPY . .

CMD ["python3", "sensor_bridge.py"]
