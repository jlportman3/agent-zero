This directory contains Docker build scripts and patches for customizing the myrun container.

**Important rules for Codex**

- Do **not** modify any files outside of `docker/myrun`.
- All changes to the Agent-Zero source code must be placed as patch files in `docker/myrun/patches/`.
- The Dockerfile applies these patches during the container build.
- Never alter files in the repository's root source tree directly.
