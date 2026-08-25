#!/usr/bin/env bash
#
# Cloud Agent install phase for RediStick.
# Installs the two things the project needs to build and test:
#   1. Redis 8 (Community Edition) with the bundled JSON / Search / TimeSeries /
#      Bloom / VectorSet modules, matching the `redis:8` service used in CI.
#   2. The smalltalkCI test runner, which downloads the pinned Pharo VM + image
#      on first use.
#
# The script is idempotent: it can run repeatedly against a clean or a partially
# prepared machine.
set -euo pipefail

REDIS_KEYRING=/usr/share/keyrings/redis-archive-keyring.gpg
REDIS_LIST=/etc/apt/sources.list.d/redis.list
SMALLTALKCI_HOME="${HOME}/smalltalkCI"

install_redis() {
  if command -v redis-server >/dev/null 2>&1; then
    echo "redis-server already installed: $(redis-server --version)"
    return 0
  fi

  echo "Installing Redis 8 from packages.redis.io ..."
  sudo apt-get update -qq
  sudo apt-get install -y -qq lsb-release curl gpg ca-certificates

  curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o "${REDIS_KEYRING}"
  sudo chmod 644 "${REDIS_KEYRING}"
  echo "deb [signed-by=${REDIS_KEYRING}] https://packages.redis.io/deb $(lsb_release -cs) main" \
    | sudo tee "${REDIS_LIST}" >/dev/null

  sudo apt-get update -qq
  sudo apt-get install -y -qq redis
  echo "Installed: $(redis-server --version)"
}

install_smalltalkci() {
  if [ ! -d "${SMALLTALKCI_HOME}" ]; then
    echo "Cloning smalltalkCI ..."
    git clone --depth 1 https://github.com/hpi-swa/smalltalkCI.git "${SMALLTALKCI_HOME}"
  else
    echo "smalltalkCI already present at ${SMALLTALKCI_HOME}"
  fi
  sudo ln -sf "${SMALLTALKCI_HOME}/bin/smalltalkci" /usr/local/bin/smalltalkci
  echo "smalltalkci available at $(command -v smalltalkci)"
}

install_redis
install_smalltalkci

echo "RediStick install phase complete."
