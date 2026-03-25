/*
 * qt-stdio-calculator
 * Simple Qt GUI calculator using stdio backends (Bash/PHP).
 *
 * Copyright (c) 2025 Graduate. Damian Williamson
 * Licensed under the MIT License.
 * Created collaboratively by MR and Copilot (Microsoft AI).
 */

#include <QApplication>
#include <QWidget>
#include <QGridLayout>
#include <QPushButton>
#include <QLineEdit>
#include <QProcess>
#include <QTextStream>
#include <QCoreApplication>
#include <QDebug>

/*
 * Custom Qt message handler to suppress specific noisy warnings:
 * - QSocketNotifier: Can only be used with threads started with QThread
 * We still print all other messages to stderr.
 */
void customMessageHandler(QtMsgType type,
                          const QMessageLogContext &context,
                          const QString &msg)
{
    Q_UNUSED(context);

    if (type == QtWarningMsg) {
        if (msg.startsWith("QSocketNotifier: Can only be used with threads started with QThread")) {
            // Suppress this specific warning
            return;
        }
    }

    QByteArray local = msg.toLocal8Bit();
    fprintf(stderr, "%s\n", local.constData());
}

/*
 * CalculatorGui
 *
 * - Renders a simple calculator UI (0–9, +, -, *, /, =, C).
 * - Launches a backend process (PHP by default, Bash optional).
 * - Sends key presses to the backend via stdin.
 * - Receives display updates from the backend via stdout.
 *
 * Protocol:
 *   GUI → backend:   "KEY <symbol>\n"
 *   backend → GUI:   "DISPLAY <value>\n"
 */
class CalculatorGui : public QWidget {
    Q_OBJECT

public:
    explicit CalculatorGui(QWidget *parent = nullptr)
        : QWidget(parent),
          display(nullptr),
          backend(nullptr)
    {
        setWindowTitle("STDIO Calculator");

        // Create the display line edit (read-only, right-aligned).
        display = new QLineEdit(this);
        display->setReadOnly(true);
        display->setAlignment(Qt::AlignRight);
        display->setText("0");

        // Layout for display + buttons.
        auto *layout = new QGridLayout(this);
        layout->addWidget(display, 0, 0, 1, 4);

        // Calculator buttons in a 4x4 grid.
        QStringList buttons = {
            "7","8","9","+",
            "4","5","6","-",
            "1","2","3","*",
            "C","0","=","/"
        };

        int row = 1;
        int col = 0;
        for (const QString &text : buttons) {
            QPushButton *btn = new QPushButton(text, this);
            layout->addWidget(btn, row, col);

            // When a button is clicked, send its text as a KEY command.
            connect(btn, &QPushButton::clicked, this, [this, text]() {
                sendKey(text);
            });

            ++col;
            if (col == 4) {
                col = 0;
                ++row;
            }
        }

        // Decide which backend to use:
        // - Default: Calculator.php
        // - Override: --BASH or --PHP on the command line.
        QString backendProgram = QCoreApplication::applicationDirPath() + "/Calculator.php";

        const QStringList args = QCoreApplication::arguments();
        if (args.contains("--BASH", Qt::CaseInsensitive)) {
            backendProgram = QCoreApplication::applicationDirPath() + "/Calculator.sh";
        } else if (args.contains("--PHP", Qt::CaseInsensitive)) {
            backendProgram = QCoreApplication::applicationDirPath() + "/Calculator.php";
        }

        // Launch the backend process.
        backend = new QProcess(this);
        backend->setProgram(backendProgram);
        backend->start();

        // Read DISPLAY lines from backend stdout.
        connect(backend, &QProcess::readyReadStandardOutput,
                this, &CalculatorGui::readBackend);
    }

    ~CalculatorGui() override
    {
        // Cleanly terminate the backend to avoid:
        // "QProcess: Destroyed while process is still running."
        if (backend) {
            backend->terminate();
            if (!backend->waitForFinished(1000)) {
                backend->kill();
                backend->waitForFinished(1000);
            }
        }
    }

private slots:
    /*
     * readBackend()
     *
     * Called whenever the backend has data on stdout.
     * We read line-by-line and look for "DISPLAY <value>" messages.
     */
    void readBackend() {
        while (backend->canReadLine()) {
            QString line = backend->readLine().trimmed();

            if (line.startsWith("DISPLAY ")) {
                QString value = line.mid(QString("DISPLAY ").length());
                display->setText(value);
            }
        }
    }

private:
    /*
     * sendKey()
     *
     * Sends a single key press to the backend as:
     *   "KEY <symbol>\n"
     */
    void sendKey(const QString &key) {
        if (!backend)
            return;

        QByteArray msg = "KEY " + key.toUtf8() + "\n";
        backend->write(msg);
        backend->waitForBytesWritten(10);  // small timeout, usually immediate
    }

    QLineEdit *display;
    QProcess  *backend;
};

int main(int argc, char *argv[])
{
    // Install custom message handler to filter noisy warnings.
    qInstallMessageHandler(customMessageHandler);

    QApplication app(argc, argv);
    CalculatorGui w;
    w.show();
    return app.exec();
}

#include "main.moc"
