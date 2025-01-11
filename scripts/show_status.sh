#!/bin/bash
while true; do
  clear
  echo "╔═══════════════════════════════════════╗"
  echo "║           MCP Server Status           ║"
  echo "╚═══════════════════════════════════════╝"
  echo
  echo "🕒 Current Time: $(date '+%Y-%m-%d %H:%M:%S')"
  echo "📡 Server Status: Active"
  echo "🔄 Last 5 Events:"
  echo "----------------------------------------"
  tail -n 5 "$1" | grep -v "Starting MCP Server" || echo "No events yet"
  echo
  echo "Press Ctrl-C to exit status view"
  sleep 1
done
