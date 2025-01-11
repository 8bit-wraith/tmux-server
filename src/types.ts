/**
 * Types for tmux session management
 * @module types
 */

/**
 * Represents a tmux session
 */
export interface TmuxSession {
  id: string;
  name: string;
  created: Date;
  attached: boolean;
  windows: TmuxWindow[];
}

/**
 * Represents a tmux window
 */
export interface TmuxWindow {
  id: string;
  name: string;
  active: boolean;
  panes: TmuxPane[];
}

/**
 * Represents a tmux pane
 */
export interface TmuxPane {
  id: string;
  active: boolean;
  width: number;
  height: number;
  command: string;
  pid: number;
}

/**
 * Tmux command response
 */
export interface TmuxCommandResponse {
  success: boolean;
  output: string;
  error?: string;
}

/**
 * Session creation options
 */
export interface CreateSessionOptions {
  name: string;
  width?: number;
  height?: number;
  command?: string;
}

/**
 * Session attachment options
 */
export interface AttachOptions {
  readonly?: boolean;
  width?: number;
  height?: number;
} 