# 🤍 White Belt Hints

**Hint 1:** A workflow file needs exactly three top-level keys to be valid: `name`, `on`, and `jobs`. Make sure all three are present and correctly indented.

**Hint 2:** The `on:` key takes the name of a GitHub event. For a push trigger, it's simply `on: push`.

**Hint 3:** Job IDs go *under* the `jobs:` key, indented by two spaces. The job ID is what you call it — in this case `greet`.

**Hint 4:** Every job needs a `runs-on:` and a `steps:` list. Each step can have a `name:` and a `run:` key.

**Hint 5 (structure):** If you're completely lost, the shape looks like this:
```yaml
name: My Workflow
on: push
jobs:
  my-job-name:
    runs-on: ubuntu-latest
    steps:
      - name: Step name
        run: echo "something"
```
