FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Create directories
RUN mkdir -p data logs config

# Non-root user
RUN useradd -m -u 1000 nexusai && chown -R nexusai:nexusai /app
USER nexusai

EXPOSE 8000

CMD ["python", "main.py"]
