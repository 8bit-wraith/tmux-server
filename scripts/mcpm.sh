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
    echo "║  🎮 MCPM Integration Assistant 🎮    ║"
    echo "║   'Making package management fun!'    ║"
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
    echo -e "${BLUE}Choose your MCPM destiny:${NC}"
    echo -e "${CYAN}1)${NC} Install MCPM CLI"
    echo -e "${CYAN}2)${NC} Register Package"
    echo -e "${CYAN}3)${NC} Update Package"
    echo -e "${CYAN}4)${NC} Validate Config"
    echo -e "${CYAN}5)${NC} Start as MCP Server"
    echo -e "${CYAN}6)${NC} Check MCPM Status"
    echo -e "${CYAN}q)${NC} Quit"
}

# MCPM Functions
install_mcpm() {
    announce "Installing MCPM CLI - Let's get this party started! 🎉"
    run_command "npm install -g @mcpm/cli"
}

register_package() {
    announce "Registering our package with MCPM - Time to shine! ✨"
    run_command "mcpm add --self"
}

update_package() {
    announce "Updating our package in MCPM - Keeping things fresh! 🌟"
    run_command "mcpm update @mcp/tmux-interface"
}

validate_config() {
    announce "Validating our MCPM configuration - Let's check those numbers! 📊"
    if [ -f ".mcpmrc" ]; then
        run_command "cat .mcpmrc | jq"
        echo -e "${GREEN}✨ Configuration looks valid!${NC}"
    else
        echo -e "${RED}💔 Oops! .mcpmrc file not found!${NC}"
        exit 1
    fi
}

start_mcp_server() {
    announce "Starting as an MCP server - Time to show Claude what we've got! 🚀"
    run_command "mcpm mcp"
}

check_status() {
    announce "Checking MCPM status - Let's see how we're doing! 🔍"
    run_command "mcpm list"
}

# Main Logic
main() {
    show_header

    # Handle direct commands
    case "$1" in
        "install")
            install_mcpm
            return
            ;;
        "register")
            register_package
            return
            ;;
        "update")
            update_package
            return
            ;;
        "validate")
            validate_config
            return
            ;;
        "start")
            start_mcp_server
            return
            ;;
        "status")
            check_status
            return
            ;;
    esac

    # Interactive menu if no direct command
    while true; do
        show_menu
        read -p "Enter your choice: " choice
        case $choice in
            1) install_mcpm ;;
            2) register_package ;;
            3) update_package ;;
            4) validate_config ;;
            5) start_mcp_server ;;
            6) check_status ;;
            q) 
                announce "See you later, package manager! 📦"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice! Try again...${NC}"
                ;;
        esac
    done
}

# Make it happen!
main "$@" 