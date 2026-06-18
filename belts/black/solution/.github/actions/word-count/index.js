const core = require('@actions/core');

async function run() {
  const text = core.getInput('text', { required: true });
  const words = text.trim() === '' ? [] : text.trim().split(/\s+/);
  const count = words.length;

  core.info(`Word count: ${count}`);
  core.setOutput('count', count);
}

run().catch(core.setFailed);
