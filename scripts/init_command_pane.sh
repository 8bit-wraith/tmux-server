#!/bin/bash

# Set up history
export HISTFILE="/Users/wraith/Documents/Cline/MCP/tmux-server/logs/commands_2025-01-11_02-45-17.log"
export HISTSIZE=50000
export HISTFILESIZE=50000
export HISTCONTROL=ignorespace

# Add scripts to PATH
export PATH="/Users/wraith/Documents/Cline/MCP/tmux-server/scripts:$PATH"

# Custom prompt
export PS1="🤖 MCP> "

# Save history with timestamp
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

# Define help function
help() {
  cat << 'HELP'
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
HELP
}
