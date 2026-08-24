#!/usr/bin/env bash
#
# Cloud Agent start phase for RediStick.
# Brings up a local Redis 8 server with the modules RediStick exercises
# (Search, JSON, TimeSeries, Bloom; VectorSet is built into Redis 8 core).
# Idempotent: a no-op if Redis is already responding.
set -euo pipefail

MODULES_DIR=/usr/lib/redis/modules

if redis-cli ping >/dev/null 2>&1; then
  echo "Redis already running."
  exit 0
fi

module_flags=()
for mod in redisearch rejson redistimeseries redisbloom; do
  if [ -f "${MODULES_DIR}/${mod}.so" ]; then
    module_flags+=(--loadmodule "${MODULES_DIR}/${mod}.so")
  fi
done

redis-server --daemonize yes --save "" --appendonly no "${module_flags[@]}"

for _ in $(seq 1 30); do
  if redis-cli ping >/dev/null 2>&1; then
    echo "Redis is ready."
    redis-cli module list | tr '\n' ' '
    echo
    exit 0
  fi
  sleep 1
done

echo "Redis did not become ready in time." >&2
exit 1
