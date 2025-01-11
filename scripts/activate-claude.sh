#!/bin/bash

# Colors for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# ASCII art for MCP activation
show_header() {
  echo -e "${BLUE}"
  echo "╔═══════════════════════════════════════╗"
  echo "║          MCP Activation Panel         ║"
  echo "║    Connecting Claude to Tmux Server   ║"
  echo "╚═══════════════════════════════════════╝"
  echo -e "${NC}"
}

# Trisha's encouraging messages
ACTIVATION_QUOTES=(
  "Initiating neural handshake! 🧠"
  "Powering up the digital synapses! ⚡"
  "Establishing quantum entanglement! 🌌"
  "Synchronizing parallel processes! 🔄"
  "Loading AI consciousness matrix! 🤖"
)

random_quote() {
  local idx=$((RANDOM % ${#ACTIVATION_QUOTES[@]}))
  echo "${ACTIVATION_QUOTES[$idx]}"
}

# Check if tmux is installed
check_dependencies() {
  if ! command -v tmux &> /dev/null; then
    echo -e "${RED}Error: tmux is not installed!${NC}"
    echo -e "${YELLOW}Please install tmux first:${NC}"
    echo "brew install tmux  # for macOS"
    echo "apt install tmux   # for Ubuntu/Debian"
    exit 1
  fi
}

# Create a new session for Claude
create_claude_session() {
  local session_name="claude"
  
  # Kill existing session if it exists
  tmux kill-session -t "$session_name" 2>/dev/null
  
  # Create new session
  tmux new-session -d -s "$session_name"
  
  # Configure the session
  tmux set-option -t "$session_name" status-bg blue
  tmux set-option -t "$session_name" status-fg white
  tmux set-option -t "$session_name" status-right "#[fg=white]MCP Active"
  
  echo -e "${GREEN}✓ Claude session created${NC}"
}

# Main activation sequence
main() {
  show_header
  
  echo -e "${PURPLE}💫 $(random_quote)${NC}"
  
  echo -e "${YELLOW}Checking dependencies...${NC}"
  check_dependencies
  
  echo -e "${YELLOW}Creating Claude session...${NC}"
  create_claude_session
  
  echo -e "${GREEN}🎉 MCP activation complete!${NC}"
  echo -e "${BLUE}To connect Claude to this session:${NC}"
  echo -e "1. Use session name: ${YELLOW}claude${NC}"
  echo -e "2. Copy this command into Claude: ${YELLOW}tmux attach -t claude${NC}"
  echo
  echo -e "${PURPLE}Trisha says: Ready to revolutionize AI interaction! 🚀${NC}"
}

# Run the activation sequence
main "$@" 