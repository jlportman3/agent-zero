FROM python:3.12-slim

# --- Metadata ---
ARG BRANCH
ARG CACHE_DATE=none
ENV BRANCH=${BRANCH:-main}

# --- System Dependencies ---
RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        bash curl git build-essential nano \
        openssh-server supervisor \
        python3-venv libxfixes3 libxrandr2 libgbm1 libxkbcommon0 libasound2 && \
    rm -rf /var/lib/apt/lists/*

# Add the searxng user required by supervisord
RUN useradd --system --create-home \
    --home-dir /usr/local/searxng \
    --shell /bin/bash searxng && \
    mkdir -p /usr/local/searxng && \
    chown -R searxng:searxng /usr/local/searxng

# Install uv package manager used by Agent Zero
RUN curl -Ls https://astral.sh/uv/install.sh | UV_INSTALL_DIR=/usr/local/bin sh

# --- Copy the Agent-Zero Source ---
# Copy runtime files to /a0 so /a0/ins and /a0/exe are available
COPY ./fs/ /
COPY ./patches/ /patches/

RUN mkdir -p /opt \
    && python -m venv /opt/venv

RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && apt-get upgrade -y
# --- Installation Scripts (Agent-Zero) ---
RUN chmod +x /ins/*.sh /exe/*.sh
RUN --mount=type=cache,target=/root/.cache \
    bash /ins/pre_install.sh "$BRANCH"
RUN --mount=type=cache,target=/root/.cache \
    bash /ins/install_A0.sh "$BRANCH" && \
        for p in /patches/*.patch; do \
            patch -d /git/agent-zero -p1 < "$p"; \
        done
RUN --mount=type=cache,target=/root/.cache \
    bash /ins/install_additional.sh "$BRANCH"
RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && apt-get upgrade -y

# --- Cache Busting Build Layer ---
RUN --mount=type=cache,target=/root/.cache \
    echo "cache bust $CACHE_DATE" && bash /ins/install_A02.sh "$BRANCH"

# --- Finalize ---
RUN --mount=type=cache,target=/root/.cache \
    bash /ins/post_install.sh "$BRANCH"

# --- Executables ---
RUN chmod +x /exe/initialize.sh /exe/run_A0.sh /exe/run_searxng.sh /exe/run_tunnel_api.sh

# --- Ports ---
EXPOSE 22 80 9000-9009

# --- Entrypoint ---
CMD ["/exe/initialize.sh", "${BRANCH}"]
