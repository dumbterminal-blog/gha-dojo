# 🟠 Orange Belt — Job Dependencies

> *"Jobs bow to your orchestration. Pipelines fear your sequencing."*

---

## What you'll learn

- How to run multiple jobs in a workflow
- How to create dependencies between jobs using `needs:`
- How to pass **outputs** from one job to another
- The difference between parallel and sequential job execution

---

## The Challenge

Open `.github/workflows/pipeline.yml`.

Build a three-job pipeline that runs in sequence:

```
[build] ──► [test] ──► [report]
```

### Job 1: `build`
- Runs on `ubuntu-latest`
- Has one step that echoes `Building the project...`
- Sets a **job output** called `artifact-name` with the value `my-app-v1.0`

### Job 2: `test`
- **Depends on** `build`
- Runs on `ubuntu-latest`
- Has one step that echoes `Running tests...`
- Also sets an output called `test-result` with the value `passed`

### Job 3: `report`
- **Depends on both** `build` and `test`
- Runs on `ubuntu-latest`
- Reads and prints the outputs from both previous jobs:
  - `Built artifact: <artifact-name from build job>`
  - `Test result: <test-result from test job>`

---

## Key concepts

### Job outputs

A job exposes data to downstream jobs via `outputs:`:

```yaml
jobs:
  my-job:
    runs-on: ubuntu-latest
    outputs:
      my-output: ${{ steps.my-step.outputs.value }}   # references a step output
    steps:
      - name: Produce a value
        id: my-step                                    # step must have an id
        run: echo "value=hello-world" >> $GITHUB_OUTPUT
```

Three things are needed:
1. The **step** must have an `id`
2. The step writes `key=value` to `$GITHUB_OUTPUT`
3. The **job** declares an `outputs:` block that maps a name to a step output

### Job dependencies and reading outputs

```yaml
  downstream-job:
    needs: my-job              # or needs: [job-a, job-b] for multiple
    runs-on: ubuntu-latest
    steps:
      - run: echo "${{ needs.my-job.outputs.my-output }}"
```

Use `needs.<job-id>.outputs.<output-name>` to read from an upstream job.

---

> 💡 **Hint:** Run `./dojo hint orange` if you get stuck.
