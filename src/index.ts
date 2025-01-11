#!/usr/bin/env node

/**
 * MCP server implementation for tmux integration using control mode
 * Allows Claude.app to interact with tmux sessions through:
 * - Listing active sessions as resources
 * - Reading session content
 * - Creating and managing sessions via tools
 * - Sending commands to sessions
 */

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListResourcesRequestSchema,
  ListToolsRequestSchema,
  ReadResourceRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import { TmuxManager } from "./tmux-manager.js";

// Get singleton instance of TmuxManager
const tmux = TmuxManager.getInstance();

// Connect to tmux in control mode
await tmux.connect();

// Handle cleanup on exit
process.on('exit', () => {
  tmux.disconnect();
});

process.on('SIGINT', () => {
  tmux.disconnect();
  process.exit();
});

process.on('SIGTERM', () => {
  tmux.disconnect();
  process.exit();
});

/**
 * Create MCP server with capabilities for resources and tools
 */
const server = new Server(
  {
    name: "mcp-tmux-server",
    version: "0.1.0",
  },
  {
    capabilities: {
      resources: {},
      tools: {},
      hooks: {}, // Enable hooks for real-time updates
    },
  }
);

/**
 * Handler for listing available tmux sessions as resources
 * Each session is exposed as a resource with:
 * - A tmux:// URI scheme
 * - Text/plain MIME type
 * - Human readable name and description
 */
server.setRequestHandler(ListResourcesRequestSchema, async () => {
  const sessions = await tmux.listSessions();
  
  return {
    resources: sessions.map(session => ({
      uri: `tmux://${session.name}`,
      mimeType: "text/plain",
      name: session.name,
      description: `Tmux session: ${session.name} (Created: ${session.created.toLocaleString()})`,
    }))
  };
});

/**
 * Handler for reading the contents of a specific tmux session
 * Takes a tmux:// URI and returns the session content as plain text
 */
server.setRequestHandler(ReadResourceRequestSchema, async (request) => {
  const sessionName = new URL(request.params.uri).hostname;
  const windows = await tmux.getWindows(sessionName);
  
  let content = '';
  
  // Capture content from all panes in all windows
  for (const window of windows) {
    const panes = await tmux.getPanes(sessionName, window.id);
    for (const pane of panes) {
      const paneContent = await tmux.capturePane(sessionName, window.id, pane.id);
      content += `=== Window: ${window.name} | Pane: ${pane.id} ===\n${paneContent}\n\n`;
    }
  }

  return {
    contents: [{
      uri: request.params.uri,
      mimeType: "text/plain",
      text: content || "Empty session"
    }]
  };
});

/**
 * Handler that lists available tools for tmux session management
 */
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "create_session",
        description: "Create a new tmux session",
        inputSchema: {
          type: "object",
          properties: {
            name: {
              type: "string",
              description: "Name of the session"
            },
            command: {
              type: "string",
              description: "Initial command to run (optional)"
            },
            width: {
              type: "number",
              description: "Terminal width (optional)"
            },
            height: {
              type: "number",
              description: "Terminal height (optional)"
            }
          },
          required: ["name"]
        }
      },
      {
        name: "kill_session",
        description: "Kill a tmux session",
        inputSchema: {
          type: "object",
          properties: {
            name: {
              type: "string",
              description: "Name of the session to kill"
            }
          },
          required: ["name"]
        }
      },
      {
        name: "send_command",
        description: "Send a command to a tmux session",
        inputSchema: {
          type: "object",
          properties: {
            session: {
              type: "string",
              description: "Session name"
            },
            window: {
              type: "string",
              description: "Window ID"
            },
            pane: {
              type: "string",
              description: "Pane ID"
            },
            command: {
              type: "string",
              description: "Command to send"
            }
          },
          required: ["session", "window", "pane", "command"]
        }
      }
    ]
  };
});

/**
 * Handler for tmux management tools
 */
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  switch (request.params.name) {
    case "create_session": {
      const { name, command, width, height } = request.params.arguments as any;
      const result = await tmux.executeCommand(`new-session -d -s "${name}" ${command ? `-n "${command}"` : ''} ${width ? `-x ${width}` : ''} ${height ? `-y ${height}` : ''}`);
      
      return {
        content: [{
          type: "text",
          text: result.success 
            ? `Created tmux session: ${name}`
            : `Failed to create session: ${result.error}`
        }]
      };
    }

    case "kill_session": {
      const { name } = request.params.arguments as any;
      const result = await tmux.executeCommand(`kill-session -t "${name}"`);
      
      return {
        content: [{
          type: "text",
          text: result.success
            ? `Killed tmux session: ${name}`
            : `Failed to kill session: ${result.error}`
        }]
      };
    }

    case "send_command": {
      const { session, window, pane, command } = request.params.arguments as any;
      const result = await tmux.sendKeys(session, window, pane, command);
      
      return {
        content: [{
          type: "text",
          text: result.success
            ? `Sent command to ${session}:${window}.${pane}`
            : `Failed to send command: ${result.error}`
        }]
      };
    }

    default:
      throw new Error("Unknown tool");
  }
});

/**
 * Start the server using stdio transport
 */
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch((error) => {
  console.error("Server error:", error);
  tmux.disconnect();
  process.exit(1);
});
