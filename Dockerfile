# Use official slim Python image
FROM python:3.11-slim

# Set working directory at project root
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY src ./src

# Expose FastAPI port
EXPOSE 8000

# Run FastAPI app
CMD ["uvicorn", "src.todo_api.main:app", "--host", "0.0.0.0", "--port", "8000"]
