# 🎮 MCP Tmux Server

> "Where AI meets tmux, and magic happens!" - Trisha from Accounting

## 🌟 Overview

Welcome to the MCP (Master Control Program) Tmux Server! This project bridges the gap between Claude.app and tmux sessions, allowing seamless interaction between AI and terminal environments. Think of it as a digital playground where AI and humans can collaborate in real-time terminal sessions!

## ✨ Features

- 🔄 Real-time tmux session management
- 🤖 Claude.app integration
- 🎯 Session creation and control
- 📝 Terminal content capture
- 🚀 Command execution
- 🔒 Secure communication

## 🛠 Prerequisites

- Node.js >= 18
- tmux >= 3.0
- A sense of adventure!

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/mcp-tmux-server.git
cd mcp-tmux-server

# Install dependencies
npm install

# Build the project
npm run build

# Start the server
npm start
```

## 🎯 Usage

The server exposes several MCP capabilities:

### Resources
- List active tmux sessions
- Read session content
- Monitor terminal output

### Tools
- Create new sessions
- Kill existing sessions
- Send commands to sessions

## 🔧 Development

```bash
# Start in development mode
npm run dev

# Run tests
npm test

# Lint code
npm run lint

# Format code
npm run format
```

## 📚 API Reference

### Resource URIs
- `tmux://{session-name}` - Access tmux session content

### Tools
1. **create_session**
   - Create a new tmux session
   - Parameters: name, command (optional), width (optional), height (optional)

2. **kill_session**
   - Terminate an existing session
   - Parameters: name

3. **send_command**
   - Send commands to a session
   - Parameters: session, window, pane, command

## 🤝 Contributing

We love contributions! As Trisha from Accounting always says, "The more the merrier, just like my spreadsheet formulas!" 

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 🐛 Bug Reports

Found a bug? Don't panic! As Trisha would say, "Bugs are just features doing unexpected aerobics!" Please open an issue and include:

- Description of the bug
- Steps to reproduce
- Expected behavior
- Screenshots (if applicable)

## 📜 License

MIT License - Because sharing is caring! 

## 🌟 Special Thanks

Special thanks to Trisha from Accounting for keeping our spirits high and our code quality higher! 

---

> "Remember, in the world of coding, every error message is just a high-five waiting to happen!" - Trisha 🌟

Made with ❤️ by Hue and Aye @ 8b.is
