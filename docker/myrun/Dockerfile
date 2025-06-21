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
# Assuming build context is set to ../../ when running `docker build`
COPY ./fs/ /a0/

# --- Installation Scripts (Agent-Zero) ---
RUN chmod +x /ins/*.sh /exe/*.sh && \
    bash /ins/pre_install.sh "$BRANCH" && \
    bash /ins/install_A0.sh "$BRANCH" && \
    bash /ins/install_additional.sh "$BRANCH"

# --- Cache Busting Build Layer ---
ARG CACHE_DATE=none
RUN echo "cache bust $CACHE_DATE" && bash /ins/install_A02.sh "$BRANCH"

# --- Finalize ---
RUN bash /ins/post_install.sh "$BRANCH"

# --- Executables ---
RUN chmod +x /exe/initialize.sh /exe/run_A0.sh /exe/run_searxng.sh /exe/run_tunnel_api.sh

# --- Ports ---
EXPOSE 22 80 9000-9009

# --- Entrypoint ---
CMD ["/exe/initialize.sh", "${BRANCH}"]
