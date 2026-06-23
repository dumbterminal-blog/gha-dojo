const core = require('@actions/core');

async function run() {
  // TODO: Read the 'text' input (required)
  const text = core.getInput('text');

  // TODO: Count the words by splitting on whitespace
  //       Hint: text.trim().split(/\s+/) gives you an array of words
  //       Watch out for empty strings!
  const words = text.trim().split(" ");
  const count = words.length;

  // TODO: Log "Word count: <n>" using core.info
  core.info(`Word count: ${count}`);

  // TODO: Set the 'count' output
  core.setOutput('count', count);
}

run().catch(core.setFailed);
