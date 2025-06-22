#!/bin/bash
set -e

# Apply all patches except fix_install_A0.patch to the agent-zero repository
for p in /patches/*.patch; do
    case "$p" in
        */fix_install_A0.patch) continue ;;
    esac
    echo "Applying patch: $p"
    patch -d /git/agent-zero -p1 < "$p"
done
