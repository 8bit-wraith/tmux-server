#!/bin/bash

# 🎨 Colors make life better! - Trisha from Accounting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# 📢 Trisha's Wisdom
TRISHA_QUOTES=(
    "Remember to keep those commits atomic! Just like my coffee ☕"
    "Git is like accounting - everything needs to balance! 📊"
    "These changes look fantastic! Keep up the great work! 🌟"
    "Another beautiful commit for the books! 📚"
    "Making history, one commit at a time! 🎯"
)

random_quote() {
    rand=$((RANDOM % ${#TRISHA_QUOTES[@]}))
    echo "${TRISHA_QUOTES[$rand]}"
}

# Check if we got a commit message
if [ $# -eq 0 ]; then
    echo -e "${RED}💔 Oops! You forgot to tell me what changed!${NC}"
    echo -e "${YELLOW}Usage: $0 \"Your awesome commit message\"${NC}"
    exit 1
fi

# Get current branch name
BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Show what's about to be committed
echo -e "${BLUE}🔍 Let's see what we're working with...${NC}"
git status

# Show the diff
echo -e "${YELLOW}📝 Here's what changed:${NC}"
git diff --staged

# Confirm the commit
echo -e "${PURPLE}💼 Trisha from Accounting says: ${NC}${GREEN}$(random_quote)${NC}"
read -p "Ready to commit? (y/n): " confirm

if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
    # Add all changes
    git add .
    
    # Commit with the provided message
    git commit -m "$1"
    
    # Push to the current branch
    echo -e "${YELLOW}🚀 Pushing to $BRANCH...${NC}"
    git push origin $BRANCH
    
    echo -e "${GREEN}✨ All done! Your code is now immortalized in git history!${NC}"
else
    echo -e "${RED}🛑 Commit cancelled. Come back when you're ready!${NC}"
    exit 0
fi 