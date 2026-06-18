const core = require('@actions/core');

async function run() {
  // TODO: Read the 'text' input (required)
  const text = core.getInput(???);

  // TODO: Count the words by splitting on whitespace
  //       Hint: text.trim().split(/\s+/) gives you an array of words
  //       Watch out for empty strings!
  const words = ???;
  const count = ???;

  // TODO: Log "Word count: <n>" using core.info
  core.info(???);

  // TODO: Set the 'count' output
  core.setOutput(???, ???);
}

run().catch(core.setFailed);
