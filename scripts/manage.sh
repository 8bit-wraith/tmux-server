#!/bin/bash

# 🎨 Colors make life better! - Trisha from Accounting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# 🎭 Fun ASCII Art because why not?
show_header() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════╗"
    echo "║  🎮 MCP - Master Control Program 🎮   ║"
    echo "║    'Where AI meets tmux, finally!'    ║"
    echo "╚═══════════════════════════════════════╝"
    echo -e "${NC}"
}

# 📢 Trisha's Announcement System
announce() {
    echo -e "${PURPLE}💼 Trisha from Accounting says:${NC} ${GREEN}$1${NC}"
}

# 🚀 Command Runner with Style
run_command() {
    echo -e "${YELLOW}🔧 Running:${NC} $1"
    eval $1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✨ Success!${NC}"
    else
        echo -e "${RED}💔 Oopsie! Something went wrong...${NC}"
        exit 1
    fi
}

# 📋 Show the menu unless we have direct commands
show_menu() {
    echo -e "${BLUE}Choose your destiny:${NC}"
    echo -e "${CYAN}1)${NC} Start MCP Server"
    echo -e "${CYAN}2)${NC} Stop MCP Server"
    echo -e "${CYAN}3)${NC} Restart MCP Server"
    echo -e "${CYAN}4)${NC} Run Tests"
    echo -e "${CYAN}5)${NC} Check Status"
    echo -e "${CYAN}6)${NC} Start Dev Server"
    echo -e "${CYAN}7)${NC} Clean Project"
    echo -e "${CYAN}8)${NC} Install Dependencies"
    echo -e "${CYAN}9)${NC} Update Dependencies"
    echo -e "${CYAN}10)${NC} Activate Claude Session"
    echo -e "${CYAN}11)${NC} List Tmux Sessions"
    echo -e "${CYAN}12)${NC} Kill All Sessions"
    echo -e "${CYAN}q)${NC} Quit"
}

# 🎯 Main Logic
main() {
    show_header

    # Handle direct commands
    case "$1" in
        "start")
            start_server
            return
            ;;
        "stop")
            stop_server
            return
            ;;
        "restart")
            restart_server
            return
            ;;
        "test")
            run_tests
            return
            ;;
        "status")
            check_status
            return
            ;;
        "dev")
            dev_server
            return
            ;;
        "clean")
            clean_project
            return
            ;;
        "install")
            install_deps
            return
            ;;
        "update")
            update_deps
            return
            ;;
        "activate")
            activate_claude
            return
            ;;
        "sessions")
            list_sessions
            return
            ;;
        "killall")
            kill_all_sessions
            return
            ;;
    esac

    # Interactive menu if no direct command
    while true; do
        show_menu
        read -p "Enter your choice: " choice
        case $choice in
            1) start_server ;;
            2) stop_server ;;
            3) restart_server ;;
            4) run_tests ;;
            5) check_status ;;
            6) dev_server ;;
            7) clean_project ;;
            8) install_deps ;;
            9) update_deps ;;
            10) activate_claude ;;
            11) list_sessions ;;
            12) kill_all_sessions ;;
            q) 
                announce "See you later, alligator! 🐊"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice! Try again...${NC}"
                ;;
        esac
    done
}

# 🚀 Server Management Functions
start_server() {
    announce "Starting up the MCP server in control mode! Let's show Claude what we've got! 🚀"
    
    # Create logs directory if it doesn't exist
    mkdir -p "$ROOT_DIR/logs"
    
    # Generate timestamped log files
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    LOG_FILE="$ROOT_DIR/logs/mcp-server_$TIMESTAMP.log"
    ERROR_LOG="$ROOT_DIR/logs/mcp-server_$TIMESTAMP.error.log"
    
    # Create symlinks to latest logs
    ln -sf "$LOG_FILE" "$ROOT_DIR/logs/mcp-server.log"
    ln -sf "$ERROR_LOG" "$ROOT_DIR/logs/mcp-server.error.log"
    
    # Build the project first
    announce "Building the project..."
    run_command "pnpm build"
    
    # Start the server as a daemon
    announce "Starting MCP server daemon..."
    cd "$ROOT_DIR"
    NODE_ENV=production nohup pnpm start > "$LOG_FILE" 2> "$ERROR_LOG" & echo $! > "$ROOT_DIR/logs/mcp-server.pid"
    
    # Give it a moment to start
    sleep 2
    
    # Check if server started successfully
    if [ -f "$ROOT_DIR/logs/mcp-server.pid" ] && ps -p $(cat "$ROOT_DIR/logs/mcp-server.pid") > /dev/null; then
        # Check logs for any startup errors
        if grep -i "error" "$ERROR_LOG" > /dev/null; then
            echo -e "${RED}Server started but encountered errors:${NC}"
            cat "$ERROR_LOG"
            stop_server
            exit 1
        fi
        
        announce "MCP server is running in the background! Check logs for details 📝"
        echo -e "${YELLOW}Logs available at:${NC}"
        echo -e "  ${CYAN}Output:${NC} $LOG_FILE"
        echo -e "  ${CYAN}Errors:${NC} $ERROR_LOG"
        echo -e "  ${CYAN}Latest logs linked at:${NC} logs/mcp-server.log"
        
        # Show initial server output
        echo -e "\n${CYAN}Initial server output:${NC}"
        tail -n 5 "$LOG_FILE"
    else
        echo -e "${RED}Failed to start MCP server! Check error log for details:${NC}"
        cat "$ERROR_LOG"
        exit 1
    fi
}

stop_server() {
    announce "Shutting down MCP and cleaning up tmux sessions... Don't worry, it'll be back! 🛑"
    
    # Kill the server using PID file if it exists
    if [ -f "$ROOT_DIR/logs/mcp-server.pid" ]; then
        run_command "kill $(cat \"$ROOT_DIR/logs/mcp-server.pid\") 2>/dev/null || true"
        rm -f "$ROOT_DIR/logs/mcp-server.pid"
    else
        run_command "pkill -f 'node.*mcp-server' 2>/dev/null || true"
    fi
    
    # Clean up tmux sessions
    run_command "tmux kill-session -t mcp 2>/dev/null || true"
}

restart_server() {
    announce "Time for a quick refresh! BRB! 🔄"
    stop_server
    sleep 2
    start_server
}

run_tests() {
    announce "Running tests! Fingers crossed for those control mode tests! 🤞"
    run_command "pnpm test"
}

check_status() {
    announce "Let's see what's cooking in our tmux sessions! 🔍"
    
    # Check MCP server status using PID file
    echo -e "${YELLOW}MCP Server Status:${NC}"
    if [ -f "$ROOT_DIR/logs/mcp-server.pid" ] && ps -p $(cat "$ROOT_DIR/logs/mcp-server.pid") > /dev/null; then
        echo -e "${GREEN}MCP server is running (PID: $(cat "$ROOT_DIR/logs/mcp-server.pid"))${NC}"
        echo -e "${CYAN}Last 5 log entries:${NC}"
        tail -n 5 "$ROOT_DIR/logs/mcp-server.log" 2>/dev/null || echo "No log entries yet"
        
        if [ -f "$ROOT_DIR/logs/mcp-server.error.log" ]; then
            echo -e "\n${YELLOW}Recent errors (if any):${NC}"
            tail -n 5 "$ROOT_DIR/logs/mcp-server.error.log" 2>/dev/null
        fi
    else
        echo -e "${RED}MCP server is not running${NC}"
    fi
    
    # Check tmux sessions
    echo -e "\n${YELLOW}Tmux Sessions:${NC}"
    run_command "tmux list-sessions 2>/dev/null || echo 'No active tmux sessions'"
}

# Development commands
dev_server() {
    announce "Starting development server with hot reload! Watch that control mode magic! 🔥"
    run_command "pnpm dev"
}

clean_project() {
    announce "Time for some spring cleaning! 🧹"
    run_command "pnpm clean"
}

install_deps() {
    announce "Installing dependencies with pnpm! 📦"
    run_command "pnpm install"
}

update_deps() {
    announce "Updating dependencies to their latest versions! 🚀"
    run_command "pnpm update"
}

# Tmux Session Management
activate_claude() {
    announce "Activating Claude's tmux session! Time for some AI magic! ✨"
    run_command "$SCRIPT_DIR/activate-claude.sh"
}

list_sessions() {
    announce "Here are all our active tmux sessions! 📋"
    run_command "tmux list-sessions 2>/dev/null || echo 'No active tmux sessions'"
}

kill_all_sessions() {
    announce "Cleaning up all tmux sessions! Fresh start incoming! 🧹"
    run_command "tmux kill-server 2>/dev/null || echo 'No tmux server running'"
}

# Make it happen!
main "$@" 