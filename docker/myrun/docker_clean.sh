#!/bin/bash
# Clean unused Docker data and optionally older images/containers
set -e

DAYS=${1:-0}

if [ "$DAYS" -gt 0 ]; then
    HOURS=$((DAYS*24))
    docker container prune -f --filter "until=${HOURS}h"
    docker image prune -f --filter "until=${HOURS}h"
fi

docker system prune -a --volumes -f

