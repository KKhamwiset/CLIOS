# ============================================================
# CLIOS - CLI-based OSPF Simulator
# ============================================================

# --------------- Stage 1: Build dependencies ----------------
FROM python:3.11-slim AS builder

WORKDIR /build

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# --------------- Stage 2: Runtime ---------------------------
FROM python:3.11-slim

LABEL maintainer="CLIOS Team"
LABEL description="C.L.I.O.S. - CLI-based OSPF Simulator"

# Install system dependencies (Graphviz for topology rendering)
RUN apt-get update && \
    apt-get install -y --no-install-recommends graphviz && \
    rm -rf /var/lib/apt/lists/*

# Copy installed Python packages from builder stage
COPY --from=builder /install /usr/local

WORKDIR /app

# Copy application source code
COPY chat.py .
COPY cli_engine.py .
COPY llm_engine.py .
COPY network_state.py .
COPY rag/ ./rag/

# Copy pre-built FAISS index and chunks data
COPY faiss.index .
COPY chunks.pkl .

# Create output directory for topology renders
RUN mkdir -p /app/output

# Copy environment file (override at runtime via docker run --env-file)
COPY .env .

# Run the interactive CLI
CMD ["python", "-u", "chat.py"]
