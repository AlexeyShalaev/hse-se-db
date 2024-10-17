FROM python:3.12-rc-slim-buster

RUN apt-get update && \
    apt-get install -y gcc libpq-dev curl && \
    apt clean && \
    rm -rf /var/cache/apt/*

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=utf-8 \
    PYTHONPATH=/app

COPY requirements.txt .

RUN pip install -U pip && \
    pip install --no-cache-dir -r requirements.txt

COPY alembic.ini /app/

COPY ./migrations /app/migrations

COPY ./src /app/src

WORKDIR /app

CMD ["python", "src/main.py"]
