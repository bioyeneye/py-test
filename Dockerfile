# Use official slim Python image
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app

# Set working directory at project root
WORKDIR /app

RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*


# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY src ./src

# Create data directory
RUN mkdir -p /app/data && \
    chmod 777 /app/data

HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1
    
# Expose FastAPI port
EXPOSE 8000

# Run FastAPI app
CMD ["uvicorn", "src.todo_api.main:app", "--host", "0.0.0.0", "--port", "8000"]
