#!/usr/bin/env bash
#
# Calculator.sh
# Bash backend for qt-stdio-calculator.
#
# Protocol:
#   GUI → backend:   "KEY <symbol>"
#   backend → GUI:   "DISPLAY <value> <op>"
#
# <value> = current numeric display
# <op>    = C, +, -, *, /, =, or empty
#
# Continued mathematics:
#   2 + 3 = 5, then pressing * 4 = gives 20, etc.
#
# Copyright (c) 2025 Graduate. Damian Williamson.
# Licensed under the MIT License.
# Created collaboratively by Graduate. Damian Williamson and Copilot (Microsoft AI).

update_display() {
    # $1 = value, $2 = operator
    printf "DISPLAY %s %s\n" "$1" "$2"
}

current=""
operand=""
operator=""

# Initial display
update_display "0" ""

while IFS= read -r line; do
    [[ -z "$line" ]] && continue

    if [[ "$line" == KEY\ * ]]; then
        key=${line#KEY }

        case "$key" in
            C)
                current=""
                operand=""
                operator=""
                update_display "0" "C"
                ;;
            "+"|"-"|"*"|"/")
                # If we already have operand/operator/current, compute first (continued maths)
                if [[ -n "$operand" && -n "$operator" && -n "$current" ]]; then
                    result=$(echo "$operand $operator $current" | bc 2>/dev/null)
                    operand="$result"
                    current=""
                    operator="$key"
                    update_display "$operand" "$operator"
                else
                    # Start a new operation
                    operand="$current"
                    current=""
                    operator="$key"
                    update_display "$operand" "$operator"
                fi
                ;;
            "=")
                if [[ -n "$operand" && -n "$operator" && -n "$current" ]]; then
                    result=$(echo "$operand $operator $current" | bc 2>/dev/null)
                    current="$result"
                    operand=""
                    operator="="
                    update_display "$current" "$operator"
                else
                    # No full expression; just echo current
                    update_display "${current:-0}" "="
                fi
                ;;
            [0-9])
                current+="$key"
                update_display "$current" "$operator"
                ;;
        esac
    fi
done
