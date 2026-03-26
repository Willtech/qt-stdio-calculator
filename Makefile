# Makefile
# Top-level build and dependency orchestration for qt-stdio-calculator.
#
# Copyright (c) 2025 MR.
# Licensed under the MIT License.

PROJECT_DIR := $(CURDIR)
TARGET      := qt-calculator-gui
QMAKE       ?= qmake-qt5
QMAKE_OUT   := Makefile.qt

PREFIX      ?= /usr/local
BINDIR      := $(PREFIX)/bin

.PHONY: all build clean deps ensure-groot install

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

install: $(TARGET)
	@echo "[qt-stdio-calculator] Installing to $(BINDIR)..."   # ⟶ TAB
	@mkdir -p "$(BINDIR)"                                      # ⟶ TAB
	@cp "$(TARGET)" "$(BINDIR)/$(TARGET)"                      # ⟶ TAB
	@echo "[qt-stdio-calculator] Installed $(TARGET)."         # ⟶ TAB

clean:
	@if [ -f "$(QMAKE_OUT)" ]; then \                          # ⟶ TAB
		$(MAKE) -f $(QMAKE_OUT) clean; \
	fi
	@rm -f "$(QMAKE_OUT)" "$(TARGET)"                          # ⟶ TAB
