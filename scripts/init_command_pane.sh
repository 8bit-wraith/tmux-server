#!/bin/bash
# Set up history
export HISTFILE="/Users/wraith/Documents/Cline/MCP/tmux-server/logs/commands_2025-01-11_02-32-48.log"
export HISTSIZE=50000
export HISTFILESIZE=50000

# Disable command echoing in history
export HISTCONTROL=ignorespace

# Custom prompt to show we're in MCP
export PS1="🤖 MCP> "

# Function to save history with timestamp
save_history() {
  local cmd=$(history 1 | cut -c 8-)
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $cmd" >> "$HISTFILE"
}
export PROMPT_COMMAND="save_history"

# Show welcome message
cat << 'WELCOME'
🤖 Claude Command Interface Ready
----------------------------------------
Commands:
  history              - Show command history
  show_log            - View full server log
  follow_log          - Follow server log
  show_history        - Show combined history
  clear               - Clear screen
  help                - Show this message
----------------------------------------
WELCOME
