# --- Stage 1: Build & Requirements ---
FROM python:3.11-slim AS builder

WORKDIR /build

# Install build dependencies (gcc, headers etc if needed for c-extensions)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
# Install to a local folder to easily copy in the next stage
RUN pip install --no-cache-dir --user -r requirements.txt


# --- Stage 2: Final Production Image ---
FROM python:3.11-slim

# Best Practice: Non-root user for security
RUN groupadd -g 999 python && \
    useradd -r -u 999 -g python python

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app \
    PATH="/home/python/.local/bin:${PATH}"

WORKDIR /app

# Install only runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy only the installed packages from builder stage
COPY --from=builder /root/.local /home/python/.local
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy source code and set ownership
COPY --chown=python:python src ./src

# Create data directory with restricted permissions
RUN mkdir -p /app/data && chown python:python /app/data

# Switch to non-root user
USER python

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

EXPOSE 8000

CMD ["uvicorn", "src.todo_api.main:app", "--host", "0.0.0.0", "--port", "8000"]