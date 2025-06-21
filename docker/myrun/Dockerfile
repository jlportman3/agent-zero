FROM python:3.12-slim

# --- Metadata ---
ARG BRANCH
ENV BRANCH=${BRANCH:-main}
WORKDIR /a0

# --- System Dependencies ---
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash curl git build-essential nano \
        openssh-server supervisor \
        && apt-get clean && rm -rf /var/lib/apt/lists/*

# --- Copy the Agent-Zero Source ---
# Copy runtime files to /a0 so /a0/ins and /a0/exe are available
COPY ./fs/ /a0/

# --- Installation Scripts (Agent-Zero) ---
RUN chmod +x /a0/ins/*.sh /a0/exe/*.sh && \
    bash /a0/ins/pre_install.sh "$BRANCH" && \
    bash /a0/ins/install_A0.sh "$BRANCH" && \
    bash /a0/ins/install_additional.sh "$BRANCH"

# --- Cache Busting Build Layer ---
ARG CACHE_DATE=none
RUN echo "cache bust $CACHE_DATE" && bash /a0/ins/install_A02.sh "$BRANCH"

# --- Finalize ---
RUN bash /a0/ins/post_install.sh "$BRANCH"

# --- Executables ---
RUN chmod +x /a0/exe/initialize.sh /a0/exe/run_A0.sh /a0/exe/run_searxng.sh /a0/exe/run_tunnel_api.sh

# --- Ports ---
EXPOSE 22 80 9000-9009

# --- Entrypoint ---
CMD ["/a0/exe/initialize.sh", "${BRANCH}"]
