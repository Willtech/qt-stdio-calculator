# calculator.pro
# qmake project file for qt-stdio-calculator.
#
# Builds the qt-calculator-gui binary using Qt Widgets.

QT += widgets
CONFIG += c++11 console
TEMPLATE = app
TARGET = qt-calculator-gui
SOURCES += main.cpp
