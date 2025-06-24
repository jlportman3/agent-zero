# Use the pre-built Agent Zero base image for faster builds.
# Build the base image locally using:
#   docker build -t agent-zero-base:local ../base
FROM agent-zero-base:local

# --- Metadata ---
ARG BRANCH
ARG CACHE_DATE=none
ENV BRANCH=${BRANCH:-main}

# --- System Dependencies ---
RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        bash curl git build-essential nano \
        openssh-server supervisor cron \
        python3-venv libxfixes3 libxrandr2 libgbm1 libxkbcommon0 libasound2 \
        ffmpeg && \
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
RUN /opt/venv/bin/pip install supervisor ipython
RUN pip install supervisor ipython


RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && apt-get upgrade -y

# Install SearXNG search engine
COPY install_searxng.sh /install_searxng.sh
RUN chmod +x /install_searxng.sh && \
    /install_searxng.sh && rm /install_searxng.sh
# --- Installation Scripts (Agent-Zero) ---
RUN chmod +x /ins/*.sh /exe/*.sh
RUN --mount=type=cache,target=/root/.cache \
    bash /ins/pre_install.sh "$BRANCH"
COPY apply_patches.sh /apply_patches.sh
RUN --mount=type=cache,target=/root/.cache \
    bash /ins/install_A0.sh "$BRANCH"
RUN chmod +x /apply_patches.sh && /apply_patches.sh
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
