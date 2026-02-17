# --- Étape 1 : Build ---
FROM alpine:latest AS builder
RUN apk add --no-cache build-base
WORKDIR /app
COPY . .
RUN make

# --- Étape 2 : Runtime ---
FROM alpine:latest
RUN apk add --no-cache bash
WORKDIR /app
COPY --from=builder /app/hello .
RUN if [ -f test.sh ]; then chmod +x test.sh; fi