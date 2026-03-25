#!/usr/bin/env bash
#
# Calculator.sh
# Simple line-based calculator backend for qt-stdio-calculator.
#
# Protocol:
#   GUI → this script:   "KEY <symbol>"
#   this script → GUI:   "DISPLAY <value>"
#
# Copyright (c) 2025 Graduate. Damian Williamson.
# Licensed under the MIT License.
# Created collaboratively by Graduate. Damian Williamson and Copilot (Microsoft AI).

# Send a DISPLAY message to the GUI.
update_display() {
    printf "DISPLAY %s\n" "$1"
}

current=""
operand=""
operator=""

# Initialize display.
update_display "0"

# Main loop: read KEY commands from stdin.
while IFS= read -r line; do
    [[ -z "$line" ]] && continue

    if [[ "$line" == KEY\ * ]]; then
        key=${line#KEY }

        case "$key" in
            C)
                # Clear all state.
                current=""
                operand=""
                operator=""
                update_display "0"
                ;;
            "+"|"-"|"*"|"/")
                # Store operator and move current into operand.
                operand="$current"
                operator="$key"
                current=""
                ;;
            "=")
                # Perform calculation if we have a full expression.
                if [[ -n "$operand" && -n "$operator" && -n "$current" ]]; then
                    result=$(echo "$operand $operator $current" | bc 2>/dev/null)
                    current="$result"
                    operand=""
                    operator=""
                    update_display "$current"
                fi
                ;;
            [0-9])
                # Append digit to current input.
                current+="$key"
                update_display "$current"
                ;;
        esac
    fi
done
