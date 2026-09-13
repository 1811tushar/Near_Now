# Slim Python runtime; no feature-specific runtimes or model packages are included.
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends tesseract-ocr && rm -rf /var/lib/apt/lists/*

# Dependency install is its own layer so source-only rebuilds reuse it.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app

# Match the backend's least-privilege runtime convention.
RUN useradd --create-home --shell /usr/sbin/nologin nearnow
USER nearnow

EXPOSE 8001
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8001"]
