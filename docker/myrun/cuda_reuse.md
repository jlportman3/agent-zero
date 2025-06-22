# CUDA/Torch Environment Reuse

- Build a base image with CUDA, cuDNN and Torch installed and tag it (e.g., `a0-cuda:base`).
- Use that base image in your Dockerfile `FROM` line so layers with heavy binaries do not change.
- When updating your application code, avoid rebuilding the CUDA layer unless versions change.
- Mount persistent pip/apt caches with BuildKit (`--mount=type=cache,target=/root/.cache` and `/var/cache/apt`) to speed up installs.
- Keep CUDA libraries in a separate image so multiple projects can reference the same base without duplication.
