# qt-stdio-calculator

A simple Qt-based calculator GUI that talks to a backend over standard input/output.

The backend can be implemented in **PHP** (default) or **Bash**, and is selected at runtime:

- `./qt-calculator-gui` → uses `Calculator.php` (PHP backend, default)
- `./qt-calculator-gui --PHP` → explicitly use `Calculator.php`
- `./qt-calculator-gui --BASH` → use `Calculator.sh`

The project is designed for **Fedora** (Wayland-friendly) and uses **groot** as a privilege wrapper for dependency installation.

---

## Features

- Qt Widgets GUI (Qt 5)
- Simple calculator: digits `0–9`, operators `+ - * /`, `=`, and `C` (clear)
- Line-based IPC protocol over stdio:
  - GUI → backend: `KEY <symbol>`
  - Backend → GUI: `DISPLAY <value>`
- Two interchangeable backends:
  - `Calculator.php` (PHP + `bc`)
  - `Calculator.sh` (Bash + `bc`)
- Dependency installation via `groot`
- Clean shutdown of backend process
- Noisy Qt warnings filtered out

---

## Protocol

The GUI and backend communicate using a simple text protocol:

- **GUI → backend** (on key press):

  ```text
  KEY 7
  KEY +
  KEY 3
  KEY =
  ```

- **Backend → GUI** (to update display):

  ```text
  DISPLAY 0
  DISPLAY 7
  DISPLAY 10
  ```

The backend is responsible for maintaining calculator state and emitting `DISPLAY` lines.

---

## Dependencies

On Fedora, the project requires:

- Development tools
- Qt 5 development libraries
- PHP CLI
- `bc` (for arithmetic)
- `groot` (privilege wrapper, installed from GitHub:Willtech/groot)

These are installed via:

```bash
./install-deps.sh
```

which internally uses:

- `dnf group install "c-development"`
- `groot dnf install qt5-qtbase-devel qt5-qttools-devel gcc-c++ make`
- `groot dnf install php-cli bc`

---

## Quick Start

### 1. Full bootstrap (recommended)

From a fresh system:

```bash
curl -O https://raw.githubusercontent.com/Willtech/qt-stdio-calculator/main/install.sh
chmod +x install.sh
./install.sh
```

This will:

1. Install `git` (via `groot` or `sudo`).
2. Clone `https://github.com/Willtech/qt-stdio-calculator`.
3. Ensure `groot` is installed (via `make deps`).
4. Install all dependencies via `install-deps.sh`.
5. Build the Qt GUI.

### 2. Manual clone and build

```bash
git clone https://github.com/Willtech/qt-stdio-calculator
cd qt-stdio-calculator

# Ensure groot + deps
make deps

# Build
make build
```

Run with PHP backend (default):

```bash
./qt-calculator-gui
```

Run with Bash backend:

```bash
./qt-calculator-gui --BASH
```

---

## Files

- `main.cpp` — Qt GUI, launches backend via `QProcess`, supports `--BASH` / `--PHP`.
- `Calculator.php` — PHP backend, uses `bc` for arithmetic.
- `Calculator.sh` — Bash backend, uses `bc` for arithmetic.
- `calculator.pro` — qmake project file.
- `install-deps.sh` — installs dependencies via `groot`.
- `Makefile` — top-level build and dependency orchestration.
- `install.sh` — full bootstrap script (git clone, deps, build).

---

## Architecture

### GUI

- Built with Qt Widgets.
- Uses `QProcess` to launch the backend.
- Writes `KEY <symbol>` lines to backend stdin.
- Reads `DISPLAY <value>` lines from backend stdout.
- Filters noisy Qt warnings (e.g., `QSocketNotifier` message).

### Backend

- Stateless interface, stateful implementation.
- Maintains:
  - `current` input
  - `operand`
  - `operator`
- Uses `bc` for arithmetic in both Bash and PHP versions.

---

## License

This project is licensed under the **MIT License**.

```text
MIT License

Copyright (c) 2026 Willtech

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## Credits

- Concept, architecture, and identity conventions: **Graduate. Damian Williamson.**
- Implementation and iteration: **Graduate. Damian Williamson.** and **Copilot (Microsoft AI)**.
- Privilege wrapper: [`groot`](https://github.com/Willtech/groot) by Willtech.
```
