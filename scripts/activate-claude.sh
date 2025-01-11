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
  local timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
  local log_dir="$ROOT_DIR/logs"
  local session_log="$log_dir/mcp-server_${timestamp}.log"
  local command_log="$log_dir/commands_${timestamp}.log"
  local history_file="$log_dir/session_history.txt"
  
  # Check if session already exists
  if tmux has-session -t "$session_name" 2>/dev/null; then
    echo -e "${YELLOW}Existing Claude session found. Recreating...${NC}"
    # Save existing history before killing session
    if [ -f "$history_file" ]; then
      mv "$history_file" "${history_file}.backup"
    fi
    tmux kill-session -t "$session_name"
    sleep 1
  fi
  
  echo -e "${YELLOW}Creating new session...${NC}"
  
  # Create logs directory if it doesn't exist
  mkdir -p "$log_dir"
  
  # Create new session with MCP server and logging enabled
  if ! TMUX="" tmux new-session -d -s "$session_name" -c "$ROOT_DIR"; then
    echo -e "${RED}Failed to create session!${NC}"
    exit 1
  fi
  
  # Configure the session for better visibility
  tmux set-option -t "$session_name" status-bg blue
  tmux set-option -t "$session_name" status-fg white
  tmux set-option -t "$session_name" status-right "#[fg=white]MCP Active | %H:%M:%S"
  
  # Configure history and scrollback
  tmux set-option -t "$session_name" history-limit 50000
  tmux set-option -g -t "$session_name" set-clipboard on
  
  # Enable mouse mode for easier navigation
  tmux set-option -g -t "$session_name" mouse on
  
  # Window 0: MCP Server and Command Interface
  tmux rename-window -t "${session_name}:0" "mcp"
  
  # Split the window vertically for server and command pane
  tmux split-window -t "${session_name}:0" -v -p 30
  
  # Configure the server pane (top)
  tmux select-pane -t "${session_name}:0.0"
  # Add timestamp and session info to log header
  cat > "$session_log" << EOF
==============================================
MCP Server Session Log
Started: $(date)
Session: $session_name
==============================================

EOF
  tmux send-keys -t "${session_name}:0.0" "echo 'Starting MCP Server...' && node dist/index.js 2>&1 | tee -a $session_log" C-m
  tmux pipe-pane -t "${session_name}:0.0" "cat >> $session_log"
  
  # Configure the command pane (bottom)
  tmux select-pane -t "${session_name}:0.1"
  # Create command history script
  cat > "$ROOT_DIR/scripts/save_history.sh" << 'EOF'
#!/bin/bash
while IFS= read -r line; do
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $line" >> "$HISTFILE"
done
EOF
  chmod +x "$ROOT_DIR/scripts/save_history.sh"
  
  # Set up command logging
  tmux send-keys -t "${session_name}:0.1" "cd $ROOT_DIR" C-m
  tmux send-keys -t "${session_name}:0.1" "export HISTFILE=$command_log" C-m
  tmux send-keys -t "${session_name}:0.1" "export PROMPT_COMMAND='history 1 | cut -c 8- | $ROOT_DIR/scripts/save_history.sh'" C-m
  tmux send-keys -t "${session_name}:0.1" "HISTSIZE=50000 HISTFILESIZE=50000" C-m
  tmux send-keys -t "${session_name}:0.1" "echo '🤖 Claude Command Interface Ready'" C-m
  tmux send-keys -t "${session_name}:0.1" "echo '- Use this pane to issue commands'" C-m
  tmux send-keys -t "${session_name}:0.1" "echo '- Server output will appear in the top pane'" C-m
  tmux send-keys -t "${session_name}:0.1" "echo '- Use Ctrl-b o to switch between panes'" C-m
  tmux send-keys -t "${session_name}:0.1" "echo '- Type \"history\" to see command history'" C-m
  tmux send-keys -t "${session_name}:0.1" "echo '- Use \"cat $session_log\" to view full server log'" C-m
  tmux send-keys -t "${session_name}:0.1" "echo '- Use \"tail -f $session_log\" to follow server log'" C-m
  
  # Create a function to show session history
  cat > "$ROOT_DIR/scripts/show_history.sh" << EOF
#!/bin/bash
echo "=== MCP Session History ==="
echo "Server Log: $session_log"
echo "Command Log: $command_log"
echo
echo "=== Last Server Output ==="
tail -n 20 "$session_log"
echo
echo "=== Recent Commands ==="
tail -n 20 "$command_log"
EOF
  chmod +x "$ROOT_DIR/scripts/show_history.sh"
  
  # Set the command pane as active
  tmux select-pane -t "${session_name}:0.1"
  
  echo -e "${GREEN}✓ Claude session created${NC}"
  echo -e "${BLUE}Session layout:${NC}"
  echo -e "╔════════════════════════════╗"
  echo -e "║      MCP Server Log        ║"
  echo -e "╠════════════════════════════╣"
  echo -e "║    Command Interface       ║"
  echo -e "╚════════════════════════════╝"
  echo -e "${BLUE}Log files:${NC}"
  echo -e "- Server log: ${YELLOW}$session_log${NC}"
  echo -e "- Command log: ${YELLOW}$command_log${NC}"
  echo -e "- View history: ${YELLOW}./scripts/show_history.sh${NC}"
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