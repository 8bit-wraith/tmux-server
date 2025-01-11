import { spawn } from 'node:child_process';
import { EventEmitter } from 'node:events';
import { TmuxManager } from './tmux-manager';

jest.mock('node:child_process');

describe('TmuxManager', () => {
  let manager: TmuxManager;
  let mockProcess: any;
  let mockStdin: any;
  let mockStdout: any;
  let mockStderr: any;

  beforeEach(() => {
    mockStdin = new EventEmitter();
    mockStdin.write = jest.fn();
    mockStdin.end = jest.fn();

    mockStdout = new EventEmitter();
    mockStderr = new EventEmitter();
    
    mockProcess = new EventEmitter();
    mockProcess.stdin = mockStdin;
    mockProcess.stdout = mockStdout;
    mockProcess.stderr = mockStderr;
    mockProcess.kill = jest.fn();

    (spawn as jest.Mock).mockReturnValue(mockProcess);
    
    manager = TmuxManager.getInstance();
  });

  afterEach(() => {
    jest.clearAllMocks();
    manager.disconnect();
  });

  describe('connect', () => {
    it('should connect to tmux in control mode', async () => {
      const connectPromise = manager.connect();
      
      // Verify spawn args before emitting success
      expect(spawn).toHaveBeenCalledWith('tmux', ['-C', 'new-session', '-D', '-s', 'mcp']);
      
      // Emit spawn event to indicate success
      mockProcess.emit('spawn');
      await connectPromise;
      
      expect(manager['connected']).toBe(true);
    });

    it('should handle connection errors', async () => {
      const error = new Error('Failed to spawn tmux');
      const connectPromise = manager.connect();
      
      // Verify spawn was called
      expect(spawn).toHaveBeenCalled();
      
      // Emit error event and wait for rejection
      setImmediate(() => mockProcess.emit('error', error));
      
      // Verify promise rejects
      await expect(connectPromise).rejects.toThrow('Failed to connect to tmux: Error: Failed to spawn tmux');
      expect(manager['connected']).toBe(false);
    });
  });

  describe('executeCommand', () => {
    beforeEach(async () => {
      const connectPromise = manager.connect();
      mockProcess.emit('spawn');
      await connectPromise;
    });

    it('should send command through control mode', async () => {
      const commandPromise = manager.executeCommand('list-sessions');
      
      expect(mockStdin.write).toHaveBeenCalledWith('list-sessions\n');
      
      mockStdout.emit('data', Buffer.from('%begin 1\ntest: 1 windows\n%end 1\n'));
      
      const result = await commandPromise;
      expect(result.success).toBe(true);
      expect(result.output).toBe('test: 1 windows');
    });

    it('should handle command errors', async () => {
      const commandPromise = manager.executeCommand('invalid-command');
      
      expect(mockStdin.write).toHaveBeenCalledWith('invalid-command\n');
      
      mockStdout.emit('data', Buffer.from('%begin 1\n%error invalid command\n%end 1\n'));
      
      const result = await commandPromise;
      expect(result.success).toBe(false);
      expect(result.error).toBe('invalid command');
    });
  });

  describe('disconnect', () => {
    beforeEach(async () => {
      const connectPromise = manager.connect();
      mockProcess.emit('spawn');
      await connectPromise;
    });

    it('should disconnect cleanly', () => {
      manager.disconnect();
      
      expect(mockStdin.end).toHaveBeenCalled();
      expect(mockProcess.kill).toHaveBeenCalled();
      expect(manager['connected']).toBe(false);
    });
  });
}); 