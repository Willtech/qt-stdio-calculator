#!/usr/bin/env bash
#
# install.sh — Full bootstrap installer for qt-stdio-calculator
#
# Copyright (c) 2025
# Graduate. Damian Williamson.
# Licensed under the MIT License.
# Created collaboratively by Graduate. Damian Williamson and Copilot (Microsoft AI).

set -e

REPO_URL="https://github.com/Willtech/qt-stdio-calculator"
REPO_DIR="qt-stdio-calculator"

echo "[qt-stdio-calculator] Bootstrapping installation..."

# Ensure git exists
if ! command -v git >/dev/null 2>&1; then
    echo "[qt-stdio-calculator] git not found, installing..."
    if command -v groot >/dev/null 2>&1; then
        groot dnf install git
    else
        sudo dnf install -y git
    fi
fi

# Clone or update repository
if [ ! -d "$REPO_DIR" ]; then
    echo "[qt-stdio-calculator] Cloning repository..."
    git clone "$REPO_URL"
else
    echo "[qt-stdio-calculator] Repository already present, updating..."
    cd "$REPO_DIR"
    git pull --rebase
    cd ..
fi

cd "$REPO_DIR"

echo "[qt-stdio-calculator] Ensuring groot + dependencies..."
make deps

echo "[qt-stdio-calculator] Building project..."
make build

echo "[qt-stdio-calculator] Installing binary..."
sudo install -Dm755 qt-calculator-gui /usr/local/bin/qt-calculator-gui

echo "[qt-stdio-calculator] Installing backend scripts..."
sudo install -d /usr/local/libexec/qt-stdio-calculator
sudo install -m755 Calculator.sh /usr/local/libexec/qt-stdio-calculator/Calculator.sh
sudo install -m755 Calculator.php /usr/local/libexec/qt-stdio-calculator/Calculator.php
sudo install -m755 manpage.installer /usr/local/libexec/qt-stdio-calculator/manpage.installer

echo "[qt-stdio-calculator] Installing desktop entry..."
sudo install -Dm644 qt-calculator-gui.desktop /usr/share/applications/qt-calculator-gui.desktop

echo "[qt-stdio-calculator] Installing man page..."
sudo install -Dm644 qt-calculator-gui.1 /usr/share/man/man1/qt-calculator-gui.1
sudo gzip -f /usr/share/man/man1/qt-calculator-gui.1

echo "[qt-stdio-calculator] Installing documentation..."
sudo install -d /usr/local/share/doc/qt-stdio-calculator
sudo install -m644 README.md /usr/local/share/doc/qt-stdio-calculator/README.md

echo "[qt-stdio-calculator] Installing license..."
sudo install -d /usr/local/share/licenses/qt-stdio-calculator
sudo install -m644 LICENSE /usr/local/share/licenses/qt-stdio-calculator/LICENSE

echo "[qt-stdio-calculator] Build complete."
echo "[qt-stdio-calculator] Run \`cd ./qt-calculator-gui\`"
echo "[qt-stdio-calculator] You can run ./qt-calculator-gui now."
