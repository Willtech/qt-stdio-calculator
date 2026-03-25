#!/usr/bin/env bash
#
# install-deps.sh
# Install build and runtime dependencies for qt-stdio-calculator using groot.
#
# This script assumes groot is already installed and available in PATH.
#
# Copyright (c) 2025 MR.
# Licensed under the MIT License.
# Created collaboratively by MR and Copilot (Microsoft AI).

set -e

echo "[qt-stdio-calculator] Installing dependencies via groot..."

# Core development tools.
groot dnf group install "c-development"

# Qt development stack.
groot dnf install \
    qt5-qtbase-devel \
    qt5-qttools-devel \
    gcc-c++ \
    make

# Backends: PHP CLI and bc for arithmetic.
groot dnf install \
    php-cli \
    bc

echo "[qt-stdio-calculator] Dependencies installed successfully."
