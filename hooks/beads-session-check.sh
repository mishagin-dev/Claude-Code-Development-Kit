#!/bin/bash
# Beads session check hook
# Runs at session start to show ready tasks

# Only run if beads is initialized in this project
if [ ! -d ".beads" ]; then
    exit 0
fi

# Check if bd command is available
if ! command -v bd &> /dev/null; then
    exit 0
fi

# Check for ready tasks (silent fail)
ready_output=$(bd ready 2>/dev/null)

if [ -n "$ready_output" ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📌 Beads tasks ready to work on:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$ready_output"
    echo ""
    echo "Run /bd:work to start working on a task."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
fi
