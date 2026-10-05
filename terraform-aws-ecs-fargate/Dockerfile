FROM python:3.13-slim-trixie AS builder

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

FROM python:3.13-slim-trixie

ENV DB=postgres \
    DEBUG=False \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    libpq5 \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --system --uid 1000 --no-create-home app

COPY --from=builder /opt/venv /opt/venv

WORKDIR /app
COPY . .

RUN python manage.py collectstatic --noinput && python manage.py compress

USER app

EXPOSE 8000

CMD [ "gunicorn", "hc.wsgi:application", "--bind", "0.0.0.0:8000" ]
