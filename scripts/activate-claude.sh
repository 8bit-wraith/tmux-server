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

# Ensure tmux server is running
ensure_server() {
  echo -e "${YELLOW}Starting tmux server...${NC}"
  tmux start-server
  sleep 1  # Give the server a moment to initialize
  
  # Verify server is running
  if ! tmux list-sessions &>/dev/null; then
    echo -e "${RED}Failed to start tmux server!${NC}"
    echo -e "${YELLOW}Trying to fix common issues...${NC}"
    
    # Clean up potential stale socket
    rm -f /tmp/tmux-$UID/default 2>/dev/null
    
    # Try starting server again
    tmux start-server
    sleep 1
    
    if ! tmux list-sessions &>/dev/null; then
      echo -e "${RED}Could not start tmux server. Please try:${NC}"
      echo "1. Kill any existing tmux processes: pkill tmux"
      echo "2. Remove tmux socket: rm -f /tmp/tmux-$UID/default"
      echo "3. Run this script again"
      exit 1
    fi
  fi
  
  echo -e "${GREEN}✓ Tmux server running${NC}"
}

# Create a new session for Claude
create_claude_session() {
  local session_name="claude"
  
  # Check if session already exists
  if tmux has-session -t "$session_name" 2>/dev/null; then
    echo -e "${YELLOW}Existing Claude session found. Recreating...${NC}"
    tmux kill-session -t "$session_name"
    sleep 1
  fi
  
  # Create new session with a default command
  if ! tmux new-session -d -s "$session_name" "echo 'MCP Ready'; bash"; then
    echo -e "${RED}Failed to create session!${NC}"
    exit 1
  fi
  
  # Configure the session
  tmux set-option -t "$session_name" status-bg blue
  tmux set-option -t "$session_name" status-fg white
  tmux set-option -t "$session_name" status-right "#[fg=white]MCP Active"
  
  # Verify session exists
  if ! tmux has-session -t "$session_name" 2>/dev/null; then
    echo -e "${RED}Session creation failed!${NC}"
    exit 1
  fi
  
  echo -e "${GREEN}✓ Claude session created${NC}"
}

# Main activation sequence
main() {
  show_header
  
  echo -e "${PURPLE}💫 $(random_quote)${NC}"
  
  echo -e "${YELLOW}Checking dependencies...${NC}"
  check_dependencies
  
  ensure_server
  
  echo -e "${YELLOW}Creating Claude session...${NC}"
  create_claude_session
  
  echo -e "${GREEN}🎉 MCP activation complete!${NC}"
  echo -e "${BLUE}To connect Claude to this session:${NC}"
  echo -e "1. Use session name: ${YELLOW}claude${NC}"
  echo -e "2. Copy this command into Claude: ${YELLOW}tmux attach -t claude${NC}"
  echo
  echo -e "${PURPLE}Trisha says: Ready to revolutionize AI interaction! 🚀${NC}"
  
  # Show current tmux sessions
  echo -e "\n${BLUE}Current tmux sessions:${NC}"
  tmux list-sessions
}

# Run the activation sequence
main "$@" 