import { TmuxManager } from './tmux-manager.js';
import { exec } from 'node:child_process';
import type { ExecException, ChildProcess } from 'node:child_process';

// Define the type for exec callback
type ExecCallback = (error: ExecException | null, stdout: string, stderr: string) => void;

// Mock the entire child_process module
jest.mock('node:child_process', () => ({
  exec: jest.fn((
    command: string,
    options: any,
    callback?: ExecCallback
  ): ChildProcess => {
    if (typeof options === 'function') {
      callback = options;
    }
    callback?.(null, '', '');
    return { pid: 123 } as ChildProcess;
  }),
}));

// Get the mocked exec function
const mockExec = jest.mocked(exec);

describe('TmuxManager', () => {
  let manager: TmuxManager;

  beforeEach(() => {
    jest.clearAllMocks();
    manager = TmuxManager.getInstance();
  });

  describe('getInstance', () => {
    it('should return the same instance on multiple calls', () => {
      const instance1 = TmuxManager.getInstance();
      const instance2 = TmuxManager.getInstance();
      expect(instance1).toBe(instance2);
    });
  });

  describe('listSessions', () => {
    it('should parse tmux sessions correctly', async () => {
      const mockOutput = '$1|test-session|1709251234|1\n$2|another-session|1709251235|0';
      mockExec.mockImplementation((command, options, callback) => {
        if (typeof options === 'function') {
          callback = options;
        }
        callback?.(null, mockOutput, '');
        return { pid: 123 } as ChildProcess;
      });

      const sessions = await manager.listSessions();
      
      expect(sessions).toHaveLength(2);
      expect(sessions[0]).toEqual({
        id: '$1',
        name: 'test-session',
        created: expect.any(Date),
        attached: true,
        windows: [],
      });
      expect(sessions[1]).toEqual({
        id: '$2',
        name: 'another-session',
        created: expect.any(Date),
        attached: false,
        windows: [],
      });
    });

    it('should handle empty output', async () => {
      mockExec.mockImplementation((command, options, callback) => {
        if (typeof options === 'function') {
          callback = options;
        }
        callback?.(null, '', '');
        return { pid: 123 } as ChildProcess;
      });

      const sessions = await manager.listSessions();
      expect(sessions).toHaveLength(0);
    });

    it('should handle errors', async () => {
      mockExec.mockImplementation((command, options, callback) => {
        if (typeof options === 'function') {
          callback = options;
        }
        callback?.(new Error('tmux not running') as ExecException, '', 'error');
        return { pid: 123 } as ChildProcess;
      });

      const sessions = await manager.listSessions();
      expect(sessions).toHaveLength(0);
    });
  });

  describe('createSession', () => {
    it('should create a session with basic options', async () => {
      mockExec.mockImplementation((command, options, callback) => {
        if (typeof options === 'function') {
          callback = options;
        }
        callback?.(null, 'Session created', '');
        return { pid: 123 } as ChildProcess;
      });

      const result = await manager.createSession({ name: 'test-session' });
      
      expect(result.success).toBe(true);
      expect(result.output).toBe('Session created');
      expect(mockExec).toHaveBeenCalledWith(
        expect.stringContaining('new-session -d -s "test-session"'),
        expect.any(Function)
      );
    });

    it('should include size parameters when provided', async () => {
      mockExec.mockImplementation((command, options, callback) => {
        if (typeof options === 'function') {
          callback = options;
        }
        callback?.(null, 'Session created', '');
        return { pid: 123 } as ChildProcess;
      });

      await manager.createSession({
        name: 'test-session',
        width: 80,
        height: 24,
      });

      expect(mockExec).toHaveBeenCalledWith(
        expect.stringContaining('-x 80 -y 24'),
        expect.any(Function)
      );
    });

    it('should handle errors', async () => {
      mockExec.mockImplementation((command, options, callback) => {
        if (typeof options === 'function') {
          callback = options;
        }
        callback?.(new Error('Session exists') as ExecException, '', 'error');
        return { pid: 123 } as ChildProcess;
      });

      const result = await manager.createSession({ name: 'test-session' });
      expect(result.success).toBe(false);
      expect(result.error).toBeDefined();
    });
  });

  describe('sendKeys', () => {
    it('should send keys to the specified pane', async () => {
      mockExec.mockImplementation((command, options, callback) => {
        if (typeof options === 'function') {
          callback = options;
        }
        callback?.(null, 'Keys sent', '');
        return { pid: 123 } as ChildProcess;
      });

      const result = await manager.sendKeys('session', 'window', 'pane', 'ls -la');
      
      expect(result.success).toBe(true);
      expect(mockExec).toHaveBeenCalledWith(
        expect.stringContaining('send-keys -t "session:window.pane" "ls -la" Enter'),
        expect.any(Function)
      );
    });
  });

  describe('capturePane', () => {
    it('should capture pane content', async () => {
      const mockContent = 'line 1\nline 2\nline 3';
      mockExec.mockImplementation((command, options, callback) => {
        if (typeof options === 'function') {
          callback = options;
        }
        callback?.(null, mockContent, '');
        return { pid: 123 } as ChildProcess;
      });

      const content = await manager.capturePane('session', 'window', 'pane');
      
      expect(content).toBe(mockContent);
      expect(mockExec).toHaveBeenCalledWith(
        expect.stringContaining('capture-pane -p -t "session:window.pane"'),
        expect.any(Function)
      );
    });
  });

  describe('isServerRunning', () => {
    it('should return true when tmux server is running', async () => {
      mockExec.mockImplementation((command, options, callback) => {
        if (typeof options === 'function') {
          callback = options;
        }
        callback?.(null, 'Sessions listed', '');
        return { pid: 123 } as ChildProcess;
      });

      const running = await manager.isServerRunning();
      expect(running).toBe(true);
    });

    it('should return false when tmux server is not running', async () => {
      mockExec.mockImplementation((command, options, callback) => {
        if (typeof options === 'function') {
          callback = options;
        }
        callback?.(new Error('No server') as ExecException, '', 'error');
        return { pid: 123 } as ChildProcess;
      });

      const running = await manager.isServerRunning();
      expect(running).toBe(false);
    });
  });

  describe('window management', () => {
    describe('getActiveWindow', () => {
      it('should return the active window', async () => {
        const mockOutput = '1|first|0|0\n2|second|1|1\n3|third|0|2';
        mockExec.mockImplementation((command, options, callback) => {
          if (typeof options === 'function') {
            callback = options;
          }
          callback?.(null, mockOutput, '');
          return { pid: 123 } as ChildProcess;
        });

        const activeWindow = await manager.getActiveWindow('test-session');
        expect(activeWindow).toEqual({
          id: '2',
          name: 'second',
          active: true,
          index: 1,
          panes: [],
        });
      });

      it('should return null when no active window found', async () => {
        mockExec.mockImplementation((command, options, callback) => {
          if (typeof options === 'function') {
            callback = options;
          }
          callback?.(null, '', '');
          return { pid: 123 } as ChildProcess;
        });

        const activeWindow = await manager.getActiveWindow('test-session');
        expect(activeWindow).toBeNull();
      });
    });

    describe('switchWindow', () => {
      it('should switch to the specified window', async () => {
        mockExec.mockImplementation((command, options, callback) => {
          if (typeof options === 'function') {
            callback = options;
          }
          callback?.(null, 'switched', '');
          return { pid: 123 } as ChildProcess;
        });

        const result = await manager.switchWindow('test-session', '2');
        expect(result.success).toBe(true);
        expect(mockExec).toHaveBeenCalledWith(
          expect.stringContaining('select-window -t "test-session:2"'),
          expect.any(Function)
        );
      });
    });

    describe('nextWindow/previousWindow', () => {
      it('should switch to next window', async () => {
        mockExec.mockImplementation((command, options, callback) => {
          if (typeof options === 'function') {
            callback = options;
          }
          callback?.(null, 'switched', '');
          return { pid: 123 } as ChildProcess;
        });

        const result = await manager.nextWindow('test-session');
        expect(result.success).toBe(true);
        expect(mockExec).toHaveBeenCalledWith(
          expect.stringContaining('next-window -t "test-session"'),
          expect.any(Function)
        );
      });

      it('should switch to previous window', async () => {
        mockExec.mockImplementation((command, options, callback) => {
          if (typeof options === 'function') {
            callback = options;
          }
          callback?.(null, 'switched', '');
          return { pid: 123 } as ChildProcess;
        });

        const result = await manager.previousWindow('test-session');
        expect(result.success).toBe(true);
        expect(mockExec).toHaveBeenCalledWith(
          expect.stringContaining('previous-window -t "test-session"'),
          expect.any(Function)
        );
      });
    });

    describe('getWindowInfo', () => {
      it('should return detailed window information', async () => {
        const mockOutput = '1|main|1|main-vertical|0|*Z';
        mockExec.mockImplementation((command, options, callback) => {
          if (typeof options === 'function') {
            callback = options;
          }
          callback?.(null, mockOutput, '');
          return { pid: 123 } as ChildProcess;
        });

        // Mock getPanes since it's called by getWindowInfo
        jest.spyOn(manager, 'getPanes').mockResolvedValue([{
          id: '1',
          active: true,
          width: 80,
          height: 24,
          command: 'bash',
          pid: 123,
        }]);

        const windowInfo = await manager.getWindowInfo('test-session', '1');
        expect(windowInfo).toEqual({
          id: '1',
          name: 'main',
          active: true,
          index: 0,
          layout: 'main-vertical',
          flags: ['*', 'Z'],
          panes: [{
            id: '1',
            active: true,
            width: 80,
            height: 24,
            command: 'bash',
            pid: 123,
          }],
        });
      });

      it('should return null on error', async () => {
        mockExec.mockImplementation((command, options, callback) => {
          if (typeof options === 'function') {
            callback = options;
          }
          callback?.(new Error('window not found') as ExecException, '', 'error');
          return { pid: 123 } as ChildProcess;
        });

        const windowInfo = await manager.getWindowInfo('test-session', '999');
        expect(windowInfo).toBeNull();
      });
    });
  });
}); 