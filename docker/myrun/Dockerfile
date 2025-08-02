# Use the pre-built Agent Zero base image for faster builds.
# Build the base image locally using:
#   docker build -t agent-zero-base:local ../base
FROM agent-zero-base:local

# --- Metadata ---
ARG BRANCH
ARG CACHE_DATE=none
ENV BRANCH=${BRANCH:-main}

# --- System Dependencies ---
# The base image already contains all the necessary system dependencies.

# --- NVIDIA Docker Toolkit ---
# Install NVIDIA Container Toolkit for GPU support (compatible with driver 535.230.02)
# CUDA libraries will be provided by the host through nvidia-docker runtime
RUN apt-get update && apt-get install -y \
    curl \
    gnupg2 \
    vim \
    telnet \
    software-properties-common \
    build-essential \
    && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
    && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
       sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
       tee /etc/apt/sources.list.d/nvidia-container-toolkit.list \
    && apt-get update \
    && apt-get install -y nvidia-container-toolkit \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set CUDA environment variables (will be populated by nvidia-docker runtime)
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

# Set OLLAMA and LM Studio URLs
ENV OLLAMA_BASE_URL=http://10.0.60.38:11434
ENV LM_STUDIO_BASE_URL=http://10.0.60.38:1234/v1

# --- Copy the Agent-Zero Source ---
# Copy runtime files to /a0 so /a0/ins and /a0/exe are available
COPY ./fs/ /
COPY ./patches/ /patches/



# --- Installation Scripts (Agent-Zero) ---
RUN chmod +x /ins/*.sh /exe/*.sh
RUN apt-get update
RUN --mount=type=cache,target=/root/.cache \
    bash /ins/pre_install.sh "$BRANCH"
COPY apply_patches.sh /apply_patches.sh
RUN --mount=type=cache,target=/root/.cache \
    bash /ins/install_A0.sh "$BRANCH"
RUN chmod +x /apply_patches.sh && /apply_patches.sh
RUN --mount=type=cache,target=/root/.cache \
    bash /ins/install_additional.sh "$BRANCH"

# --- Install CUDA-enabled PyTorch ---
RUN --mount=type=cache,target=/root/.cache \
    . /opt/venv/bin/activate && \
    pip uninstall -y torch torchvision torchaudio && \
    uv pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

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
