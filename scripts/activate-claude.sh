#!/bin/bash

# Colors for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Project root directory
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

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

# Check if dependencies are installed
check_dependencies() {
  if ! command -v tmux &> /dev/null; then
    echo -e "${RED}Error: tmux is not installed!${NC}"
    echo -e "${YELLOW}Please install tmux first:${NC}"
    echo "brew install tmux  # for macOS"
    echo "apt install tmux   # for Ubuntu/Debian"
    exit 1
  fi

  if ! command -v node &> /dev/null; then
    echo -e "${RED}Error: Node.js is not installed!${NC}"
    echo -e "${YELLOW}Please install Node.js first:${NC}"
    echo "brew install node  # for macOS"
    echo "apt install nodejs # for Ubuntu/Debian"
    exit 1
  fi

  if ! command -v pnpm &> /dev/null; then
    echo -e "${RED}Error: pnpm is not installed!${NC}"
    echo -e "${YELLOW}Please install pnpm first:${NC}"
    echo "npm install -g pnpm"
    exit 1
  fi
}

# Ensure tmux server is running
ensure_server() {
  echo -e "${YELLOW}Preparing tmux environment...${NC}"
  
  # Clean up any existing tmux processes
  if pgrep tmux >/dev/null; then
    echo -e "${YELLOW}Found existing tmux processes. Cleaning up...${NC}"
    pkill tmux
    sleep 2
  fi
  
  # Clean up socket directory
  local socket_dir="/tmp/tmux-$(id -u)"
  if [ -d "$socket_dir" ]; then
    echo -e "${YELLOW}Cleaning up tmux socket directory...${NC}"
    rm -rf "$socket_dir"
    sleep 1
  fi
  
  echo -e "${GREEN}✓ Tmux environment ready${NC}"
}

# Create MCP configuration
create_mcp_config() {
  local config_dir="$HOME/.config/claude-mcp"
  local config_file="$config_dir/config.json"
  
  # Create config directory if it doesn't exist
  mkdir -p "$config_dir"
  
  # Create MCP configuration
  cat > "$config_file" << EOF
{
  "mcpServers": {
    "tmux-server": {
      "command": "node",
      "args": [
        "$ROOT_DIR/dist/index.js"
      ],
      "env": {
        "NODE_ENV": "production",
        "MCP_SESSION": "claude"
      }
    }
  },
  "defaultConnection": {
    "type": "tmux",
    "sessionName": "claude",
    "command": "tmux attach -t claude",
    "autoReconnect": true
  },
  "capabilities": {
    "tmux": {
      "enabled": true,
      "sessions": ["claude"],
      "allowWindowManagement": true,
      "allowPaneManagement": true
    }
  }
}
EOF
  
  echo -e "${GREEN}✓ MCP configuration created at $config_file${NC}"
  
  # Show Claude the connection instructions
  echo -e "${BLUE}Claude, when you see this configuration, please:${NC}"
  echo -e "1. Note that your session name is: ${YELLOW}claude${NC}"
  echo -e "2. Use the command: ${YELLOW}tmux attach -t claude${NC}"
  echo -e "3. The MCP server will handle the connection automatically"
}

# Build the MCP server
build_mcp_server() {
  echo -e "${YELLOW}Building MCP server...${NC}"
  cd "$ROOT_DIR"
  
  if ! pnpm build; then
    echo -e "${RED}Failed to build MCP server!${NC}"
    exit 1
  fi
  
  echo -e "${GREEN}✓ MCP server built${NC}"
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
  
  echo -e "${YELLOW}Creating new session...${NC}"
  
  # Create new session with MCP server
  if ! TMUX="" tmux new-session -d -s "$session_name" -c "$ROOT_DIR" "node dist/index.js"; then
    echo -e "${RED}Failed to create session!${NC}"
    exit 1
  fi
  
  # Configure the session
  tmux set-option -t "$session_name" status-bg blue
  tmux set-option -t "$session_name" status-fg white
  tmux set-option -t "$session_name" status-right "#[fg=white]MCP Active"
  
  # Create a new window for the shell
  tmux new-window -t "$session_name" -n "shell"
  
  # Select the first window (MCP server)
  tmux select-window -t "$session_name:0"
  tmux rename-window -t "$session_name:0" "mcp-server"
  
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
  
  echo -e "${YELLOW}Setting up MCP...${NC}"
  create_mcp_config
  build_mcp_server
  
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