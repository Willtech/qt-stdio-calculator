#!/usr/bin/env php
<?php
/**
 * Calculator.php
 * PHP backend for qt-stdio-calculator.
 *
 * Protocol:
 *   GUI → backend:   "KEY <symbol>"
 *   backend → GUI:   "DISPLAY <value> <op>"
 *
 * <value> = current numeric display
 * <op>    = C, +, -, *, /, =, or empty
 *
 * Continued mathematics:
 *   2 + 3 = 5, then * 4 = gives 20, etc.
 *
 * Copyright (c) 2025 Graduate. Damian Williamson.
 * Licensed under the MIT License.
 * Created collaboratively by Graduate. Damian Williamson and Copilot (Microsoft AI).
 */

/**
 * Emit a DISPLAY line to the GUI.
 *
 * @param string $value
 * @param string $op
 * @return void
 */
function display(string $value, string $op = ''): void {
    echo "DISPLAY {$value} {$op}\n";
    flush();
}

$current  = "";
$operand  = "";
$operator = "";

// Initial display
display("0", "");

while (($line = fgets(STDIN)) !== false) {
    $line = trim($line);
    if ($line === '') {
        continue;
    }

    if (substr($line, 0, 4) === 'KEY ') {
        $key = substr($line, 4);

        switch ($key) {
            case 'C':
                $current  = "";
                $operand  = "";
                $operator = "C";
                display("0", $operator);
                break;

            case '+':
            case '-':
            case '*':
            case '/':
                // Continued maths: if we already have operand/operator/current, compute first
                if ($operand !== "" && $operator !== "" && $current !== "") {
                    $expr   = "{$operand} {$operator} {$current}";
                    $result = shell_exec("echo '$expr' | bc 2>/dev/null");
                    $operand  = trim((string)$result);
                    $current  = "";
                    $operator = $key;
                    display($operand, $operator);
                } else {
                    $operand  = $current;
                    $current  = "";
                    $operator = $key;
                    display($operand, $operator);
                }
                break;

            case '=':
                if ($operand !== "" && $operator !== "" && $current !== "") {
                    $expr   = "{$operand} {$operator} {$current}";
                    $result = shell_exec("echo '$expr' | bc 2>/dev/null");
                    $current  = trim((string)$result);
                    $operand  = "";
                    $operator = "=";
                    display($current, $operator);
                } else {
                    display($current !== "" ? $current : "0", "=");
                }
                break;

            default:
                if (ctype_digit($key)) {
                    $current .= $key;
                    display($current, $operator);
                }
                break;
        }
    }
}
