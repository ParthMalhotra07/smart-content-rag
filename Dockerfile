FROM python:3.10-slim

WORKDIR /app

# Install system dependencies required for psycopg2 (PostgreSQL) and other build tools
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy backend requirements first
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire backend directory
COPY backend/ ./backend/

# Expose the FastAPI port
EXPOSE 8000

# Set environment path so uvicorn can find app.main
ENV PYTHONPATH=/app/backend

# Run the FastAPI application
CMD ["uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "8000"]
