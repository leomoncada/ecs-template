# Build stage: install dependencies only (no app code in builder)
FROM python:3.12-slim AS builder
WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1
ENV PIP_NO_CACHE_DIR=1
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Runtime: slim base, non-root, no pip in final image
FROM python:3.12-slim AS runtime
RUN groupadd --gid 1000 appgroup \
    && useradd --uid 1000 --gid appgroup --shell /sbin/nologin --create-home appuser
WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1
ENV PATH="/home/appuser/.local/bin:$PATH"
# Copy only installed packages from builder (no pip in final image)
COPY --from=builder /root/.local /home/appuser/.local
RUN chown -R appuser:appgroup /home/appuser/.local
COPY --chown=appuser:appgroup app/ ./app/
USER appuser
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
