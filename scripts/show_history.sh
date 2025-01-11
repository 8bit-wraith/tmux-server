#!/bin/bash
echo "=== MCP Session History ==="
echo "Server Log: /Users/wraith/Documents/Cline/MCP/tmux-server/logs/mcp-server_2025-01-11_02-31-35.log"
echo "Command Log: /Users/wraith/Documents/Cline/MCP/tmux-server/logs/commands_2025-01-11_02-31-35.log"
echo
echo "=== Last Server Output ==="
tail -n 20 "/Users/wraith/Documents/Cline/MCP/tmux-server/logs/mcp-server_2025-01-11_02-31-35.log"
echo
echo "=== Recent Commands ==="
tail -n 20 "/Users/wraith/Documents/Cline/MCP/tmux-server/logs/commands_2025-01-11_02-31-35.log"
