#!/usr/bin/env php
<?php
/**
 * Calculator.php
 * Simple line-based calculator backend for qt-stdio-calculator.
 *
 * Protocol:
 *   GUI → this script:   "KEY <symbol>"
 *   this script → GUI:   "DISPLAY <value>"
 *
 * Copyright (c) 2025 Graduate. Damian Williamson.
 * Licensed under the MIT License.
 * Created collaboratively by Graduate. Damian Williamson and Copilot (Microsoft AI).
 */

/**
 * Send a DISPLAY message to the GUI.
 *
 * @param string $value
 * @return void
 */
function display(string $value): void {
    echo "DISPLAY {$value}\n";
    flush();
}

$current  = "";
$operand  = "";
$operator = "";

// Initialize display.
display("0");

// Main loop: read KEY commands from stdin.
while (($line = fgets(STDIN)) !== false) {
    $line = trim($line);
    if ($line === '') {
        continue;
    }

    if (substr($line, 0, 4) === 'KEY ') {
        $key = substr($line, 4);

        switch ($key) {
            case 'C':
                // Clear all state.
                $current  = "";
                $operand  = "";
                $operator = "";
                display("0");
                break;

            case '+':
            case '-':
            case '*':
            case '/':
                // Store operator and move current into operand.
                $operand  = $current;
                $operator = $key;
                $current  = "";
                break;

            case '=':
                // Perform calculation if we have a full expression.
                if ($operand !== "" && $operator !== "" && $current !== "") {
                    $expr   = "$operand $operator $current";
                    $result = shell_exec("echo '$expr' | bc 2>/dev/null");
                    if ($result !== null) {
                        $current  = trim($result);
                        $operand  = "";
                        $operator = "";
                        display($current);
                    } else {
                        display("ERROR");
                    }
                }
                break;

            default:
                // Digits only for now.
                if (ctype_digit($key)) {
                    $current .= $key;
                    display($current);
                }
                break;
        }
    }
}
