FROM python:3.11.3-slim AS python-base

ENV PYTHONFAULTHANDLER=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONHASHSEED=random \
    PYTHONDONTWRITEBYTECODE=1 \
    # Pip
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_DEFAULT_TIMEOUT=100 \
    PIP_ROOT_USER_ACTION=ignore \
    # Poetry
    POETRY_VERSION=1.4.2 \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=false \
    POETRY_CACHE_DIR='/var/cache/pypoetry' \
    POETRY_HOME='/usr/local'

# System deps (we don't use exact versions because it is hard to update them)
RUN apt-get update && apt-get upgrade -y \
    && apt-get install --no-install-recommends -y \
        bash \
        brotli \
        build-essential \
        curl \
        git \
    # Installing `poetry` package manager:
    # https://github.com/python-poetry/poetry
    && curl -sSL 'https://install.python-poetry.org' | python - \
    && poetry --version \
    # Cleaning cache:
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

FROM python-base AS project-setup

WORKDIR /app

COPY ./Makefile ./
COPY poetry.lock pyproject.toml ./

FROM project-setup AS dev-build

RUN poetry install --group dev --no-interaction --no-ansi --no-root
COPY . /app
CMD ["python", "bot/main.py"]

FROM project-setup AS prod-build

RUN poetry install --no-interaction --no-ansi --no-root
COPY . /app
CMD ["python", "bot/main.py", "-OO"]