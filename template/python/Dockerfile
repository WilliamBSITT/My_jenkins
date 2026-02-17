# --- Étape 1 : Builder ---
FROM python:3.11-slim AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends build-essential
COPY src/requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# --- Étape 2 : Runtime ---
FROM python:3.11-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH
COPY src/ .
COPY test.sh* . 
RUN if [ -f test.sh ]; then chmod +x test.sh; fi
ENV FLASK_APP=app.py
EXPOSE 8081
CMD ["python", "app.py"]