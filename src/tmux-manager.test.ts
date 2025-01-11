import { TmuxManager } from './tmux-manager';
import { spawn } from 'node:child_process';

// Mock child_process.spawn
jest.mock('node:child_process', () => ({
  spawn: jest.fn(),
}));

describe('TmuxManager', () => {
  let manager: TmuxManager;
  let mockSpawn: jest.MockedFunction<typeof spawn>;
  let mockStdin: any;
  let mockStdout: any;
  let mockStderr: any;
  let mockProcess: any;

  beforeEach(() => {
    // Reset mocks
    jest.clearAllMocks();

    // Create mock process with stdin/stdout/stderr
    mockStdin = {
      write: jest.fn(),
      end: jest.fn(),
    };
    mockStdout = {
      on: jest.fn(),
    };
    mockStderr = {
      on: jest.fn(),
    };
    mockProcess = {
      stdin: mockStdin,
      stdout: mockStdout,
      stderr: mockStderr,
      on: jest.fn(),
      kill: jest.fn(),
    };

    // Setup spawn mock
    mockSpawn = spawn as jest.MockedFunction<typeof spawn>;
    mockSpawn.mockReturnValue(mockProcess);

    // Get singleton instance
    manager = TmuxManager.getInstance();
  });

  describe('connect', () => {
    it('should connect to tmux in control mode', async () => {
      await manager.connect();

      expect(mockSpawn).toHaveBeenCalledWith('tmux', ['-C', 'new-session', '-D', '-s', 'mcp']);
      expect(mockStdout.on).toHaveBeenCalledWith('data', expect.any(Function));
      expect(mockStderr.on).toHaveBeenCalledWith('data', expect.any(Function));
      expect(mockProcess.on).toHaveBeenCalledWith('exit', expect.any(Function));
    });

    it('should handle connection errors', async () => {
      mockSpawn.mockImplementation(() => {
        throw new Error('Failed to spawn tmux');
      });

      await expect(manager.connect()).rejects.toThrow('Failed to spawn tmux');
    });
  });

  describe('executeCommand', () => {
    it('should send command through control mode', async () => {
      await manager.connect();

      const promise = manager.executeCommand('list-sessions');
      
      // Simulate tmux output
      const dataHandler = mockStdout.on.mock.calls[0][1];
      dataHandler('%begin 1234\r\n0: mcp: 1 windows\r\n%end 1234\r\n');

      const result = await promise;
      expect(result.success).toBe(true);
      expect(result.output).toBe('0: mcp: 1 windows');
      expect(mockStdin.write).toHaveBeenCalledWith('list-sessions\n');
    });

    it('should handle command errors', async () => {
      await manager.connect();

      const promise = manager.executeCommand('invalid-command');
      
      // Simulate error output
      const dataHandler = mockStdout.on.mock.calls[0][1];
      dataHandler('%begin 1234\r\n%error invalid command\r\n%end 1234\r\n');

      const result = await promise;
      expect(result.success).toBe(false);
      expect(result.error).toBe('invalid command');
    });
  });

  describe('disconnect', () => {
    it('should disconnect cleanly', async () => {
      await manager.connect();
      manager.disconnect();

      expect(mockStdin.end).toHaveBeenCalled();
      expect(mockProcess.kill).toHaveBeenCalled();
    });
  });
}); 