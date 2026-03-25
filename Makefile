# Makefile
# Top-level build and dependency orchestration for qt-stdio-calculator.
#
# This Makefile:
#   - Ensures groot is installed (from GitHub:Willtech/groot).
#   - Runs install-deps.sh via groot.
#   - Invokes qmake and builds qt-calculator-gui.
#
# Copyright (c) 2025 MR.
# Licensed under the MIT License.
# Created collaboratively by MR and Copilot (Microsoft AI).

PROJECT_DIR := $(CURDIR)
TARGET      := qt-calculator-gui
QMAKE       ?= qmake-qt5
QMAKE_OUT   := Makefile.qt

PREFIX      ?= /usr/local
BINDIR      := $(PREFIX)/bin

.PHONY: all build clean deps ensure-groot install

all: build

# Build the Qt GUI using qmake and a separate generated Makefile.
build: $(TARGET)

$(TARGET): main.cpp calculator.pro
    $(QMAKE) -o $(QMAKE_OUT) calculator.pro
    $(MAKE) -f $(QMAKE_OUT)

# Install groot (if missing), then run install-deps.sh via groot.
deps: ensure-groot
    ./install-deps.sh

# Ensure groot is installed from GitHub:Willtech/groot and verify with groot --version.
ensure-groot:
    @if ! command -v groot >/dev/null 2>&1; then \
        echo "[qt-stdio-calculator] groot not found, installing..."; \
        mkdir -p external; \
        cd external && { \
            if [ ! -d groot ]; then \
                git clone https://github.com/Willtech/groot.git; \
            fi; \
            cd groot; \
            ./install.sh || sudo ./install.sh || true; \
        }; \
    else \
        echo "[qt-stdio-calculator] groot already installed."; \
    fi; \
    groot --version

# Install the built binary into $(BINDIR).
install: $(TARGET)
    @echo "[qt-stdio-calculator] Installing to $(BINDIR)..."
    @mkdir -p "$(BINDIR)"
    @cp "$(TARGET)" "$(BINDIR)/$(TARGET)"
    @echo "[qt-stdio-calculator] Installed $(TARGET) to $(BINDIR)."

# Clean build artifacts.
clean:
    @if [ -f "$(QMAKE_OUT)" ]; then \
        $(MAKE) -f $(QMAKE_OUT) clean; \
    fi
    @rm -f "$(QMAKE_OUT)" "$(TARGET)"
