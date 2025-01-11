#!/bin/bash

# Colors for pretty output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Get the log directory
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$ROOT_DIR/logs"

echo -e "${BLUE}╔════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      Command History Viewer        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════╝${NC}"
echo

if [ -d "$LOG_DIR" ]; then
    echo -e "${GREEN}📜 Recent commands:${NC}\n"
    for log in "$LOG_DIR"/commands_*.log; do
        if [ -f "$log" ]; then
            echo -e "${YELLOW}From session $(basename "$log"):${NC}"
            cat "$log" | grep -v "^#" | tail -n 20
            echo
        fi
    done
else
    echo -e "${YELLOW}No command history found yet!${NC}"
    echo "History will be available after running some commands."
fi

echo -e "${BLUE}Press any key to continue...${NC}"
read -n 1
