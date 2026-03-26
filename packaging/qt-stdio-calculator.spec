Name:           qt-stdio-calculator
Version:        1.0.0
Release:        1%{?dist}
Summary:        Qt-based calculator using stdio backends (PHP/Bash)

License:        MIT
URL:            https://github.com/Willtech/qt-stdio-calculator
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  gcc-c++
BuildRequires:  make
BuildRequires:  qt5-qtbase-devel
BuildRequires:  qt5-qttools-devel
BuildRequires:  php-cli
BuildRequires:  bc

Requires:       php-cli
Requires:       bc
Requires:       qt5-qtbase

%description
qt-stdio-calculator is a Qt Widgets calculator that communicates with a
backend over standard input/output. Backends are implemented in PHP or Bash.
The GUI displays a two-line calculator-style readout and supports continued
mathematics.

%prep
%setup -q

%build
qmake-qt5 calculator.pro
%make_build

%install
rm -rf %{buildroot}

# Binary
install -d %{buildroot}/usr/local/bin
install -m 0755 qt-calculator-gui %{buildroot}/usr/local/bin/qt-calculator-gui

# Backends + helper scripts
install -d %{buildroot}/usr/local/libexec/qt-stdio-calculator
install -m 0755 Calculator.sh %{buildroot}/usr/local/libexec/qt-stdio-calculator/Calculator.sh
install -m 0755 Calculator.php %{buildroot}/usr/local/libexec/qt-stdio-calculator/Calculator.php
install -m 0755 manpage.installer %{buildroot}/usr/local/libexec/qt-stdio-calculator/manpage.installer

# Desktop entry
install -d %{buildroot}/usr/share/applications
install -m 0644 qt-calculator-gui.desktop %{buildroot}/usr/share/applications/qt-calculator-gui.desktop

# Man page
install -d %{buildroot}/usr/share/man/man1
install -m 0644 qt-calculator-gui.1 %{buildroot}/usr/share/man/man1/qt-calculator-gui.1

# Documentation
install -d %{buildroot}/usr/local/share/doc/qt-stdio-calculator
install -m 0644 README.md %{buildroot}/usr/local/share/doc/qt-stdio-calculator/README.md

# License
install -d %{buildroot}/usr/local/share/licenses/qt-stdio-calculator
install -m 0644 LICENSE %{buildroot}/usr/local/share/licenses/qt-stdio-calculator/LICENSE

%files
/usr/local/bin/qt-calculator-gui
/usr/local/libexec/qt-stdio-calculator/Calculator.sh
/usr/local/libexec/qt-stdio-calculator/Calculator.php
/usr/local/libexec/qt-stdio-calculator/manpage.installer
/usr/share/applications/qt-calculator-gui.desktop
/usr/share/man/man1/qt-calculator-gui.1.gz
/usr/local/share/doc/qt-stdio-calculator/README.md
/usr/local/share/licenses/qt-stdio-calculator/LICENSE

%changelog
* Thu Mar 27 2025 Graduate. Damian Williamson - 1.0.0-1
- Initial RPM release.
