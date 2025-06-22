#!/bin/bash
set -e

apt-get update && \
    apt-get install -y python3.12-dev python3.12-venv \
    git build-essential libxslt-dev zlib1g-dev libffi-dev libssl-dev

useradd --shell /bin/bash --system \
    --home-dir /usr/local/searxng \
    --comment 'Privacy-respecting metasearch engine' \
    searxng || true

mkdir -p /usr/local/searxng
chown -R searxng:searxng /usr/local/searxng

su - searxng -c "git clone https://github.com/searxng/searxng /usr/local/searxng/searxng-src && \
    python3 -m venv /usr/local/searxng/searx-pyenv && \
    echo '. /usr/local/searxng/searx-pyenv/bin/activate' >> /usr/local/searxng/.profile && \
    source /usr/local/searxng/searx-pyenv/bin/activate && \
    pip install --no-cache-dir -U pip setuptools wheel pyyaml && \
    cd /usr/local/searxng/searxng-src && \
    pip install --no-cache-dir --use-pep517 --no-build-isolation -e . && \
    pip cache purge"
