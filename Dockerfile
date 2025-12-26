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

EXPOSE $PORT

# Use Gunicorn production server instead of Flask dev server
CMD gunicorn --bind 0.0.0.0:${PORT:-8000} --workers 4 --worker-class sync --timeout 120 --access-logfile - --error-logfile - main:app