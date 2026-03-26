#!/usr/bin/env bash
#
# install.sh
# Full bootstrap script for qt-stdio-calculator:
#   - Installs git (via groot or sudo).
#   - Clones the project from GitHub.
#   - Ensures groot is installed.
#   - Installs dependencies via install-deps.sh.
#   - Builds the Qt GUI.
#
# Copyright (c) 2025 Graduate. Damian Williamson.
# Licensed under the MIT License.
# Created collaboratively by Graduate. Damian Williamson and Copilot (Microsoft AI).

set -e

REPO_URL="https://github.com/Willtech/qt-stdio-calculator"
REPO_DIR="qt-stdio-calculator"

echo "[qt-stdio-calculator] Bootstrapping installation..."

if ! command -v git >/dev/null 2>&1; then
    echo "[qt-stdio-calculator] git not found, installing..."
    if command -v groot >/dev/null 2>&1; then
        groot dnf install git
    else
        sudo dnf install -y git
    fi
fi

if [ ! -d "$REPO_DIR" ]; then
    echo "[qt-stdio-calculator] Cloning repository from $REPO_URL..."
    git clone "$REPO_URL"
else
    echo "[qt-stdio-calculator] Repository already present at $REPO_DIR."
fi

cd "$REPO_DIR"

echo "[qt-stdio-calculator] Ensuring groot and dependencies..."
make deps

echo "[qt-stdio-calculator] Building project..."
make build

echo "[qt-stdio-calculator] Build complete."
echo "[qt-stdio-calculator] Run \`cd ./qt-calculator-gui\`"
echo "[qt-stdio-calculator] You can run ./qt-calculator-gui now."
