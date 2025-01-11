# 🎮 @mcp/tmux-interface

Connect Claude.app to tmux sessions for enhanced interaction and collaboration!

## 🌟 Features

- Real-time tmux session management
- Command history with timestamps
- Live server status display
- Window and pane management
- Secure communication protocols
- Automatic session recovery

## 📋 Prerequisites

- Node.js >= 18
- pnpm >= 8
- tmux >= 3.3
- A sense of adventure! 🚀

## 🚀 Quick Start

1. Install dependencies:
   ```bash
   # Install pnpm if you haven't already
   npm install -g pnpm
   
   # Install project dependencies
   pnpm install
   ```

2. Activate the MCP server:
   ```bash
   ./scripts/activate-claude.sh
   ```

3. Connect Claude to the session:
   ```bash
   tmux attach -t claude
   ```

## 💫 Command Interface

Once connected, you'll have access to these commands in the MCP interface:

- `history` - Show command history
- `show_log` - View full server log
- `follow_log` - Follow server log in real-time
- `show_history` - Show combined history
- `clear` - Clear screen
- `help` - Show available commands

## 📊 Claude's MCP Capabilities

When Claude is connected through MCP, they can:

1. **View Session Content**: 
   - Claude can directly read the content of any pane in the tmux session
   - No need to manually copy/paste output
   - Claude uses MCP's built-in `read_content` capability

2. **Execute Commands**:
   - Claude can send commands to the session
   - Commands are executed in the bottom pane
   - Output is automatically visible to Claude

3. **Monitor Changes**:
   - Claude can see real-time updates in both panes
   - Server status and logs are visible in the top pane
   - Command output appears in the bottom pane

For Claude to connect and see everything, ensure:
1. The MCP server is running (`./scripts/activate-claude.sh`)
2. The configuration at `~/.config/claude-mcp/config.json` is correct
3. Claude uses the command `tmux attach -t claude` to connect

## 📊 Session Layout

```
╔════════════════════════════╗
║      MCP Server Log        ║
╠════════════════════════════╣
║    Command Interface       ║
╚════════════════════════════╝
```

- Top pane: Live server status and log feed
- Bottom pane: Interactive command interface

## ⚙️ Configuration

The MCP configuration is automatically created at `~/.config/claude-mcp/config.json` when you run the activation script. Here's what it looks like:

```json
{
  "mcpServers": {
    "tmux-server": {
      "command": "node",
      "args": ["$ROOT_DIR/dist/index.js"],
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
```

You can modify this configuration to:
- Change the session name
- Adjust server settings
- Enable/disable capabilities
- Configure auto-reconnection

## 🛠️ Development

```bash
# Start development server
pnpm dev

# Run tests
pnpm test

# Build for production
pnpm build

# Clean project
pnpm clean

# Update dependencies
pnpm update
```

## 📝 Logging

All activity is automatically logged:
- Server logs: `logs/mcp-server_*.log`
- Command history: `logs/commands_*.log`

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## 🐛 Bug Reports

Found a bug? Please open an issue with:
1. What happened
2. What you expected to happen
3. Steps to reproduce
4. Any relevant logs

## 📜 License

MIT

## 💖 Special Thanks

Special thanks to Trisha from Accounting for her endless enthusiasm and quantum computing dreams! As she always says, "The only bug is the one we haven't found yet!" 🦋

---
*"In the dance of bits and bytes, we find our digital rhythm." - Trisha, 2025*
