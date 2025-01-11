import { spawn } from 'node:child_process';
import { promisify } from 'node:util';
import { exec as execCallback } from 'node:child_process';
import type {
  TmuxSession,
  TmuxWindow,
  TmuxPane,
  TmuxCommandResponse,
  CreateSessionOptions,
  AttachOptions,
} from './types.js';

const exec = promisify(execCallback);

/**
 * Manages tmux sessions and operations
 */
export class TmuxManager {
  private static instance: TmuxManager;

  private constructor() {}

  /**
   * Get singleton instance
   */
  public static getInstance(): TmuxManager {
    if (!TmuxManager.instance) {
      TmuxManager.instance = new TmuxManager();
    }
    return TmuxManager.instance;
  }

  /**
   * Execute a tmux command
   */
  private async executeCommand(command: string): Promise<TmuxCommandResponse> {
    try {
      const { stdout, stderr } = await exec(`tmux ${command}`);
      return {
        success: !stderr,
        output: stdout.trim(),
        error: stderr ? stderr.trim() : undefined,
      };
    } catch (error) {
      return {
        success: false,
        output: '',
        error: error instanceof Error ? error.message : String(error),
      };
    }
  }

  /**
   * List all tmux sessions
   */
  public async listSessions(): Promise<TmuxSession[]> {
    const { success, output, error } = await this.executeCommand('list-sessions -F "#{session_id}|#{session_name}|#{session_created}|#{session_attached}"');
    
    if (!success || error) {
      return [];
    }

    return output.split('\n').filter(Boolean).map(line => {
      const [id, name, created, attached] = line.split('|');
      return {
        id,
        name,
        created: new Date(parseInt(created) * 1000),
        attached: attached === '1',
        windows: [], // Windows will be populated on demand
      };
    });
  }

  /**
   * Get session windows
   */
  public async getWindows(sessionName: string): Promise<TmuxWindow[]> {
    const { success, output, error } = await this.executeCommand(
      `list-windows -t "${sessionName}" -F "#{window_id}|#{window_name}|#{window_active}"`
    );

    if (!success || error) {
      return [];
    }

    return output.split('\n').filter(Boolean).map(line => {
      const [id, name, active] = line.split('|');
      return {
        id,
        name,
        active: active === '1',
        panes: [], // Panes will be populated on demand
      };
    });
  }

  /**
   * Get window panes
   */
  public async getPanes(sessionName: string, windowId: string): Promise<TmuxPane[]> {
    const { success, output, error } = await this.executeCommand(
      `list-panes -t "${sessionName}:${windowId}" -F "#{pane_id}|#{pane_active}|#{pane_width}|#{pane_height}|#{pane_current_command}|#{pane_pid}"`
    );

    if (!success || error) {
      return [];
    }

    return output.split('\n').filter(Boolean).map(line => {
      const [id, active, width, height, command, pid] = line.split('|');
      return {
        id,
        active: active === '1',
        width: parseInt(width),
        height: parseInt(height),
        command,
        pid: parseInt(pid),
      };
    });
  }

  /**
   * Create a new tmux session
   */
  public async createSession(options: CreateSessionOptions): Promise<TmuxCommandResponse> {
    const { name, width, height, command } = options;
    let cmd = `new-session -d -s "${name}"`;

    if (width && height) {
      cmd += ` -x ${width} -y ${height}`;
    }

    if (command) {
      cmd += ` "${command}"`;
    }

    return this.executeCommand(cmd);
  }

  /**
   * Attach to a tmux session
   */
  public async attachSession(sessionName: string, options: AttachOptions = {}): Promise<TmuxCommandResponse> {
    const { readonly = false, width, height } = options;
    let cmd = readonly ? 'attach-session -r' : 'attach-session';
    cmd += ` -t "${sessionName}"`;

    if (width && height) {
      cmd += ` -x ${width} -y ${height}`;
    }

    return this.executeCommand(cmd);
  }

  /**
   * Kill a tmux session
   */
  public async killSession(sessionName: string): Promise<TmuxCommandResponse> {
    return this.executeCommand(`kill-session -t "${sessionName}"`);
  }

  /**
   * Send keys to a tmux pane
   */
  public async sendKeys(sessionName: string, windowId: string, paneId: string, keys: string): Promise<TmuxCommandResponse> {
    return this.executeCommand(`send-keys -t "${sessionName}:${windowId}.${paneId}" "${keys}" Enter`);
  }

  /**
   * Capture pane content
   */
  public async capturePane(sessionName: string, windowId: string, paneId: string): Promise<string> {
    const { success, output, error } = await this.executeCommand(
      `capture-pane -p -t "${sessionName}:${windowId}.${paneId}"`
    );

    if (!success || error) {
      return '';
    }

    return output;
  }

  /**
   * Check if tmux server is running
   */
  public async isServerRunning(): Promise<boolean> {
    const { success } = await this.executeCommand('list-sessions');
    return success;
  }

  /**
   * Start tmux server if not running
   */
  public async ensureServerRunning(): Promise<boolean> {
    if (await this.isServerRunning()) {
      return true;
    }

    const { success } = await this.executeCommand('start-server');
    return success;
  }
} 