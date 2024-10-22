# `python-base` sets up all our shared environment variables
FROM python:3.11.2-slim as python-base

# python
ENV PYTHONUNBUFFERED=1 \
    # prevents python creating .pyc files
    PYTHONDONTWRITEBYTECODE=1 \
    \
    # pip
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    \
    # poetry
    # https://python-poetry.org/docs/configuration/#using-environment-variables
    POETRY_VERSION=1.0.3 \
    # make poetry install to this location
    POETRY_HOME="/opt/poetry" \
    # make poetry create the virtual environment in the project's root
    # it gets named `.venv`
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    # do not ask any interactive question
    POETRY_NO_INTERACTION=1 \
    \
    # paths
    # this is where our requirements + virtual environment will live
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"

# prepend poetry and venv to path
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        # deps for installing poetry
        curl \
        # deps for building python deps
        build-essential \
        zlib1g-dev \
        libjpeg-dev \
        libfreetype6-dev \
        liblcms2-dev \
        libopenjp2-7-dev \
        libtiff5-dev \
        libwebp-dev \
        tcl8.6-dev \
        tk8.6-dev \
        python3-tk \
        libharfbuzz-dev \
        libfribidi-dev \
        libxcb1-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Debug step: Check Python and pip versions
RUN python --version && pip --version

# install poetry - respects $POETRY_VERSION & $POETRY_HOME
RUN pip install poetry

# Debug step: Check Poetry installation
RUN poetry --version

# install postgres dependencies inside of Docker
RUN apt-get update \
    && apt-get -y install libpq-dev gcc \
    && pip install psycopg2

# Debug step: Check installed packages
RUN pip list

# copy project requirement files here to ensure they will be cached.
WORKDIR $PYSETUP_PATH
COPY poetry.lock pyproject.toml ./

# Debug step: List contents of the working directory
RUN ls -al /opt/pysetup

# install runtime deps - uses $POETRY_VIRTUALENVS_IN_PROJECT internally
RUN poetry install --no-dev

# Debug step: List installed packages after poetry install
RUN poetry show

# quicker install as runtime deps are already installed
RUN poetry install

WORKDIR /app

COPY . /app/

# Debug step: List contents of /app directory
RUN ls -al /app

EXPOSE 8000

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]