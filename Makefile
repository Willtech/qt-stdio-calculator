# Makefile
# Top-level build and dependency orchestration for qt-stdio-calculator.
#
# Copyright (c) 2025
# Graduate. Damian Williamson.
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
DOCDIR      := $(PREFIX)/share/doc/qt-stdio-calculator
LICENSEDIR  := $(PREFIX)/share/licenses/qt-stdio-calculator

SOURCES := $(wildcard *.cpp)
HEADERS := $(wildcard *.h)

.PHONY: all build clean deps ensure-groot install install-backends install-desktop install-man install-docs

# ---------------------------------------------------------------------------
# Build targets
# ---------------------------------------------------------------------------

all: build

build: $(TARGET)

# Regenerate Makefile.qt whenever any source/header changes
$(QMAKE_OUT): calculator.pro $(SOURCES) $(HEADERS)
	$(QMAKE) -o $(QMAKE_OUT) calculator.pro

# Build the binary using qmake-generated Makefile
$(TARGET): $(QMAKE_OUT) $(SOURCES) $(HEADERS)
	$(MAKE) -f $(QMAKE_OUT)

# ---------------------------------------------------------------------------
# Dependency installation (groot + install-deps.sh)
# ---------------------------------------------------------------------------

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

# ---------------------------------------------------------------------------
# Installation targets
# ---------------------------------------------------------------------------

install: $(TARGET) install-backends install-desktop install-man install-docs
	@echo "[qt-stdio-calculator] Installing binary to $(BINDIR)..."
	@mkdir -p "$(BINDIR)"
	@cp "$(TARGET)" "$(BINDIR)/$(TARGET)"
	@chmod 755 "$(BINDIR)/$(TARGET)"

install-backends:
	@echo "[qt-stdio-calculator] Installing backends..."
	@mkdir -p "$(LIBEXECDIR)"
	@cp Calculator.sh "$(LIBEXECDIR)/Calculator.sh"
	@cp Calculator.php "$(LIBEXECDIR)/Calculator.php"
	@cp manpage.installer "$(LIBEXECDIR)/manpage.installer"
	@chmod 755 "$(LIBEXECDIR)/Calculator.sh"
	@chmod 755 "$(LIBEXECDIR)/Calculator.php"
	@chmod 755 "$(LIBEXECDIR)/manpage.installer"

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
	@chmod 644 "$(MANDIR)/qt-calculator-gui.1.gz"

install-docs:
	@echo "[qt-stdio-calculator] Installing LICENSE + README..."
	@mkdir -p "$(DOCDIR)"
	@mkdir -p "$(LICENSEDIR)"
	@cp README.md "$(DOCDIR)/README.md"
	@cp LICENSE "$(LICENSEDIR)/LICENSE"
	@chmod 644 "$(DOCDIR)/README.md"
	@chmod 644 "$(LICENSEDIR)/LICENSE"

# ---------------------------------------------------------------------------
# Cleanup
# ---------------------------------------------------------------------------

clean:
	@if [ -f "$(QMAKE_OUT)" ]; then \
		$(MAKE) -f $(QMAKE_OUT) clean; \
	fi
	@rm -f "$(QMAKE_OUT)" "$(TARGET)"
