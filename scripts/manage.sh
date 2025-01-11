#!/bin/bash

# 🎨 Colors make life better! - Trisha from Accounting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

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
    announce "Starting up the MCP server! Let's show Claude what we've got! 🚀"
    run_command "pnpm start"
}

stop_server() {
    announce "Shutting down MCP... Don't worry, it'll be back! 🛑"
    run_command "pkill -f 'node.*mcp-server'"
}

restart_server() {
    announce "Time for a quick refresh! BRB! 🔄"
    stop_server
    sleep 2
    start_server
}

run_tests() {
    announce "Running tests! Fingers crossed! 🤞"
    run_command "pnpm test"
}

check_status() {
    announce "Let's see what's cooking! 🔍"
    run_command "ps aux | grep '[n]ode.*mcp-server'"
}

# Add development commands
dev_server() {
    announce "Starting development server with hot reload! 🔥"
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

# Make it happen!
main "$@" 