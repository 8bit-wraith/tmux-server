// Dependency-free characterization of the existing parser, with no tmux process.
const fs = require('node:fs');
const vm = require('node:vm');
const {stripTypeScriptTypes} = require('node:module');
const assert = require('node:assert/strict');
const test = require('node:test');
const path = require('node:path');
let source = fs.readFileSync(path.join(__dirname, '../src/tmux-manager.ts'), 'utf8');
source = source.replace(/^import .*;\r?\n/gm, '').replace('export class TmuxManager', 'class TmuxManager');
const code = stripTypeScriptTypes(source) + '\nthis.Manager = TmuxManager;';
function manager() {
  const context = {console, spawn() {throw new Error('Process spawning forbidden in this test');}};
  vm.runInNewContext(code, context);
  return context.Manager.getInstance();
}
function capture(chunks) {
  const m = manager();
  let result;
  m.commandQueue.set(1, {resolve(value) {result = value;}, reject() {}});
  chunks.forEach(chunk => m.handleTmuxOutput(chunk));
  return result;
}
test('documented single-chunk fixture resolves', () => {
  assert.equal(capture(['%begin 1700000000 258 1\nhello\n%end 1700000000 258 1\n']).output, 'hello');
});
test('same fixture resolves across every byte split', () => {
  const frame = '%begin 1700000000 258 1\nhello\n%end 1700000000 258 1\n';
  for (let split = 1; split < frame.length; split++) {
    const result = capture([frame.slice(0, split), frame.slice(split)]);
    assert.equal(result?.output, 'hello', `split at ${split}`);
  }
});
test('disconnect rejects pending command rather than abandoning it', () => {
  const m = manager();
  let rejected = false;
  m.tmuxProcess = {stdin: {end() {}}, kill() {}};
  m.commandQueue.set(1, {resolve() {}, reject() {rejected = true;}});
  m.disconnect();
  assert.equal(rejected, true);
});

test('error guard terminates a failed command', () => {
  const result = capture(['%begin 1700000000 299 1\nbad command\n%error 1700000000 299 1\n']);
  assert.equal(result.success, false);
  assert.equal(result.error, 'bad command');
});
test('startup block and notifications do not consume a queued command', () => {
  const result = capture(['%begin 1700000000 258 0\n%end 1700000000 258 0\n%session-changed $0 mcp\n',
    '%begin 1700000001 290 1\nhello\n%end 1700000001 290 1\n']);
  assert.equal(result.output, 'hello');
});
test('server command numbers map to pending commands in order', () => {
  const m = manager();
  const results = [];
  for (const id of [5, 6]) m.commandQueue.set(id, {resolve(value) {results.push(value.output);}, reject() {}});
  m.handleTmuxOutput('%begin 1700000000 900 1\none\n%end 1700000000 900 1\n%begin 1700000000 901 1\ntwo\n%end 1700000000 901 1\n');
  assert.deepEqual(results, ['one', 'two']);
});
