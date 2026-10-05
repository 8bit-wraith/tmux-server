/**
 * TmuxManager class for managing tmux sessions using control mode
 * Provides methods to:
 * - Connect to tmux in control mode
 * - Execute commands and parse responses
 * - Manage sessions, windows and panes
 * - Handle real-time updates via hooks
 */

import { spawn } from 'node:child_process';
import type { ChildProcess } from 'node:child_process';
import type { TmuxSession, TmuxWindow, TmuxPane, TmuxCommandResponse } from './types.js';

export class TmuxManager {
  private static instance: TmuxManager;
  private tmuxProcess: ChildProcess | null = null;
  private commandQueue: Map<number, { 
    resolve: (value: TmuxCommandResponse) => void;
    reject: (reason: any) => void;
  }> = new Map();
  private commandCounter = 0;
  private buffer = '';
  private connected = false;
  private responseBlock: { guard: string; commandId?: number; output: string[] } | null = null;

  private constructor() {}

  public static getInstance(): TmuxManager {
    if (!TmuxManager.instance) {
      TmuxManager.instance = new TmuxManager();
    }
    return TmuxManager.instance;
  }

  /**
   * Connect to tmux in control mode
   */
  public async connect(): Promise<void> {
    if (this.connected) {
      return;
    }

    return new Promise<void>((resolve, reject) => {
      try {
        // Start tmux in control mode
        this.tmuxProcess = spawn('tmux', ['-C', 'new-session', '-D', '-s', 'mcp']);

        // Handle stdout data
        this.tmuxProcess.stdout?.on('data', (data: Buffer) => {
          this.handleTmuxOutput(data.toString());
        });

        // Handle stderr data
        this.tmuxProcess.stderr?.on('data', (data: Buffer) => {
          console.error('Tmux error:', data.toString());
        });

        // Handle process exit
        this.tmuxProcess.on('exit', (code: number) => {
          console.error('Tmux process exited with code:', code);
          this.connected = false;
          this.rejectPending(new Error('Tmux process exited'));
        });

        // Handle process error
        this.tmuxProcess.on('error', (error: Error) => {
          this.connected = false;
          this.rejectPending(error);
          reject(new Error(`Failed to connect to tmux: ${error}`));
        });

        // Handle successful spawn
        this.tmuxProcess.on('spawn', () => {
          this.connected = true;
          resolve();
        });
      } catch (error) {
        reject(new Error(`Failed to connect to tmux: ${error}`));
      }
    });
  }

  /**
   * Handle output from tmux control mode
   */
  private handleTmuxOutput(data: string) {
    this.buffer += data;

    // A block can span any number of stdout chunks. Command numbers are
    // server-assigned; map client-command blocks to our pending FIFO queue.
    while (this.buffer.includes('\n')) {
      const newlineIndex = this.buffer.indexOf('\n');
      const line = this.buffer.slice(0, newlineIndex);
      this.buffer = this.buffer.slice(newlineIndex + 1);
      const begin = /^%begin (\d+) (\d+) (\d+)$/.exec(line);
      if (!this.responseBlock && begin) {
        this.responseBlock = {
          guard: `${begin[1]} ${begin[2]} ${begin[3]}`,
          commandId: (Number(begin[3]) & 1) !== 0
            ? this.commandQueue.keys().next().value : undefined,
          output: []
        };
        continue;
      }
      const block = this.responseBlock;
      if (!block) continue; // Asynchronous notifications are not command output.
      const success = line === `%end ${block.guard}`;
      const failure = line === `%error ${block.guard}`;
      if (success || failure) {
        const output = block.output.join('\n').trim();
        if (block.commandId !== undefined) {
          const handler = this.commandQueue.get(block.commandId);
          this.commandQueue.delete(block.commandId);
          handler?.resolve({ success, output, error: failure ? output : undefined });
        }
        this.responseBlock = null;
      } else {
        block.output.push(line);
      }
    }
  }

  /**
   * Execute a tmux command in control mode
   */
  public async executeCommand(command: string): Promise<TmuxCommandResponse> {
    if (!this.connected || !this.tmuxProcess?.stdin) {
      throw new Error('Not connected to tmux');
    }

    return new Promise((resolve, reject) => {
      const id = ++this.commandCounter;
      this.commandQueue.set(id, { resolve, reject });
      const stdin = this.tmuxProcess?.stdin;
      if (!stdin) {
        this.commandQueue.delete(id);
        reject(new Error('Tmux stdin not available'));
        return;
      }
      stdin.write(`${command}\n`);
    });
  }

  /**
   * List active tmux sessions
   */
  public async listSessions(): Promise<TmuxSession[]> {
    const result = await this.executeCommand('list-sessions -F "#{session_id}|#{session_name}|#{session_created}|#{session_attached}"');
    if (!result.success || !result.output) {
      return [];
    }

    return result.output.split('\n').map(line => {
      const [id, name, created, attached] = line.split('|');
      return {
        id,
        name,
        created: new Date(parseInt(created) * 1000),
        attached: attached === '1',
        windows: []
      };
    });
  }

  /**
   * Get windows for a session
   */
  public async getWindows(sessionName: string): Promise<TmuxWindow[]> {
    const result = await this.executeCommand(
      `list-windows -t "${sessionName}" -F "#{window_id}|#{window_name}|#{window_active}|#{window_index}|#{window_layout}|#{window_flags}"`
    );
    
    if (!result.success || !result.output) {
      return [];
    }

    return Promise.all(
      result.output.split('\n').map(async line => {
        const [id, name, active, index, layout, flags] = line.split('|');
        const panes = await this.getPanes(sessionName, id);
        return {
          id,
          name,
          active: active === '1',
          index: parseInt(index),
          layout,
          flags: flags.split(''),
          panes
        };
      })
    );
  }

  /**
   * Get panes for a window
   */
  public async getPanes(sessionName: string, windowId: string): Promise<TmuxPane[]> {
    const result = await this.executeCommand(
      `list-panes -t "${sessionName}:${windowId}" -F "#{pane_id}|#{pane_active}|#{pane_width}|#{pane_height}|#{pane_current_command}|#{pane_pid}"`
    );

    if (!result.success || !result.output) {
      return [];
    }

    return result.output.split('\n').map(line => {
      const [id, active, width, height, command, pid] = line.split('|');
      return {
        id,
        active: active === '1',
        width: parseInt(width),
        height: parseInt(height),
        command,
        pid: parseInt(pid)
      };
    });
  }

  /**
   * Send keys to a pane
   */
  public async sendKeys(sessionName: string, windowId: string, paneId: string, keys: string): Promise<TmuxCommandResponse> {
    return this.executeCommand(`send-keys -t "${sessionName}:${windowId}.${paneId}" "${keys}" Enter`);
  }

  /**
   * Capture pane content
   */
  public async capturePane(sessionName: string, windowId: string, paneId: string): Promise<string> {
    const result = await this.executeCommand(`capture-pane -p -t "${sessionName}:${windowId}.${paneId}"`);
    return result.success ? result.output : '';
  }

  /**
   * Get active window in a session
   */
  public async getActiveWindow(sessionName: string): Promise<TmuxWindow | null> {
    const windows = await this.getWindows(sessionName);
    return windows.find(w => w.active) || null;
  }

  /**
   * Switch to a specific window
   */
  public async switchWindow(sessionName: string, windowId: string): Promise<TmuxCommandResponse> {
    return this.executeCommand(`select-window -t "${sessionName}:${windowId}"`);
  }

  /**
   * Switch to next window
   */
  public async nextWindow(sessionName: string): Promise<TmuxCommandResponse> {
    return this.executeCommand(`next-window -t "${sessionName}"`);
  }

  /**
   * Switch to previous window
   */
  public async previousWindow(sessionName: string): Promise<TmuxCommandResponse> {
    return this.executeCommand(`previous-window -t "${sessionName}"`);
  }

  /**
   * Get detailed window information
   */
  public async getWindowInfo(sessionName: string, windowId: string): Promise<TmuxWindow | null> {
    const result = await this.executeCommand(
      `list-windows -t "${sessionName}:${windowId}" -F "#{window_id}|#{window_name}|#{window_active}|#{window_layout}|#{window_index}|#{window_flags}"`
    );

    if (!result.success || !result.output) {
      return null;
    }

    const [id, name, active, layout, index, flags] = result.output.split('|');
    const panes = await this.getPanes(sessionName, id);

    return {
      id,
      name,
      active: active === '1',
      index: parseInt(index),
      layout,
      flags: flags.split(''),
      panes
    };
  }

  /**
   * Disconnect from tmux
   */
  private rejectPending(error: Error): void {
    for (const handler of this.commandQueue.values()) handler.reject(error);
    this.commandQueue.clear();
    this.responseBlock = null;
    this.buffer = '';
  }

  public disconnect(): void {
    this.rejectPending(new Error('Disconnected from tmux'));
    if (this.tmuxProcess) {
      this.tmuxProcess.stdin?.end();
      this.tmuxProcess.kill();
      this.tmuxProcess = null;
    }
    this.connected = false;
    this.commandCounter = 0;
  }
}
