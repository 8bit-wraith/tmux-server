#!/bin/bash

# Colors for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Fun quotes from Trisha about git commits
TRISHA_QUOTES=(
  "Making history, one commit at a time! 🎯"
  "Git-ting things done! 🚀"
  "Another commit, another step towards perfection! ✨"
  "Committing with style and grace! 💃"
  "This code is going places! 🌟"
  "Making the codebase sparkle! ✨"
  "Git happens, but we make it fabulous! 🎨"
  "Pushing pixels and breaking barriers! 💪"
  "Code commits are like digital hugs! 🤗"
  "Version control is my cardio! 🏃‍♀️"
)

# Function to get a random quote from Trisha
random_quote() {
  local idx=$((RANDOM % ${#TRISHA_QUOTES[@]}))
  echo "${TRISHA_QUOTES[$idx]}"
}

# Check if we have a commit message
if [ $# -lt 1 ]; then
  echo -e "${RED}Error: Please provide a commit message!${NC}"
  echo -e "${YELLOW}Usage: $0 <commit message> [-y]${NC}"
  exit 1
fi

# Combine all arguments except the last one (which might be -y) into the commit message
if [[ "${@: -1}" == "-y" ]]; then
  # All args except the last one
  COMMIT_MSG="${*%${!#}}"
  AUTO_CONFIRM=true
else
  # All args
  COMMIT_MSG="$*"
  AUTO_CONFIRM=false
fi

# Get the current branch name
BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Show current status
echo -e "${BLUE}🔍 Let's see what we're working with...${NC}"
git status

# Show what changed
echo -e "${GREEN}📝 Here's what changed:${NC}"
git diff --staged

# Get a fun quote from Trisha
QUOTE=$(random_quote)
echo -e "${PURPLE}💼 Trisha from Accounting says: ${QUOTE}${NC}"

# If not auto-confirming, ask for confirmation
if [ "$AUTO_CONFIRM" = false ]; then
  read -p "Ready to commit? (y/n): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Commit cancelled. Come back when you're ready! 👋${NC}"
    exit 1
  fi
fi

# Add all changes and commit
git add .
git commit -m "$COMMIT_MSG"

# Push to the current branch
echo -e "${GREEN}🚀 Pushing to ${BRANCH}...${NC}"
git push origin "$BRANCH"

echo -e "${GREEN}✨ All done! Your code is now immortalized in git history!${NC}" 