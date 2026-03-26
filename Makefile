# Makefile
# Top-level build and dependency orchestration for qt-stdio-calculator.
#
# Copyright (c) 2025 Graduate. Damian Williamson.
# Licensed under the MIT License.

PROJECT_DIR := $(CURDIR)
TARGET      := qt-calculator-gui
QMAKE       ?= qmake-qt5
QMAKE_OUT   := Makefile.qt

PREFIX      ?= /usr/local
BINDIR      := $(PREFIX)/bin
LIBEXECDIR  := $(PREFIX)/libexec/qt-stdio-calculator
DESKTOPDIR  := /usr/share/applications
MANDIR      := /usr/share/man/man1

.PHONY: all build clean deps ensure-groot install install-backends install-desktop install-man

all: build

build: $(TARGET)

$(TARGET): main.cpp calculator.pro
    $(QMAKE) -o $(QMAKE_OUT) calculator.pro
    $(MAKE) -f $(QMAKE_OUT)

deps: ensure-groot
    ./install-deps.sh

ensure-groot:
    @if ! command -v groot >/dev/null 2>&1; then \
        echo "[qt-stdio-calculator] groot not found, installing..."; \
        mkdir -p external; \
        cd external && { \
            if [ ! -d groot ]; then \
                git clone https://github.com/Willtech/groot.git; \
            fi; \
            cd groot; \
            sudo dnf install groot-1.3.0-1.fc43.x86_64.rpm; \
        }; \
    else \
        echo "[qt-stdio-calculator] groot already installed."; \
    fi; \
    groot --version

install: $(TARGET) install-backends install-desktop install-man
    @echo "[qt-stdio-calculator] Installing binary to $(BINDIR)..."
    @mkdir -p "$(BINDIR)"
    @cp "$(TARGET)" "$(BINDIR)/$(TARGET)"
    @chmod 755 "$(BINDIR)/$(TARGET)"
    @echo "[qt-stdio-calculator] Installed $(TARGET)."

install-backends:
    @echo "[qt-stdio-calculator] Installing backends..."
    @mkdir -p "$(LIBEXECDIR)"
    @cp Calculator.sh "$(LIBEXECDIR)/Calculator.sh"
    @cp Calculator.php "$(LIBEXECDIR)/Calculator.php"
    @chmod 755 "$(LIBEXECDIR)/Calculator.sh"
    @chmod 755 "$(LIBEXECDIR)/Calculator.php"

install-desktop:
    @echo "[qt-stdio-calculator] Installing desktop entry..."
    @mkdir -p "$(DESKTOPDIR)"
    @cp qt-calculator-gui.desktop "$(DESKTOPDIR)/qt-calculator-gui.desktop"
    @chmod 644 "$(DESKTOPDIR)/qt-calculator-gui.desktop"

install-man:
    @echo "[qt-stdio-calculator] Installing man page..."
    @mkdir -p "$(MANDIR)"
    @cp qt-calculator-gui.1 "$(MANDIR)/qt-calculator-gui.1"
    @gzip -f "$(MANDIR)/qt-calculator-gui.1" || true
    @mandb >/dev/null 2>&1 || true

clean:
    @if [ -f "$(QMAKE_OUT)" ]; then \
        $(MAKE) -f $(QMAKE_OUT) clean; \
    fi
    @rm -f "$(QMAKE_OUT)" "$(TARGET)"
