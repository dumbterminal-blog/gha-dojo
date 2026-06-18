# 🟠 Orange Belt Hints

**Hint 1:** Job outputs need three things to work: a step `id`, that step writing to `$GITHUB_OUTPUT`, and the job declaring `outputs:` that maps a name to `${{ steps.<id>.outputs.<key> }}`.

**Hint 2:** To write a step output, the syntax is exactly:
```bash
echo "key=value" >> $GITHUB_OUTPUT
```
The key before `=` becomes the output name. Make sure you use `>>` not `>`.

**Hint 3:** To depend on a single job: `needs: build`. To depend on multiple: `needs: [build, test]`.

**Hint 4:** To *read* an output from a previous job in a step:
```yaml
run: echo "${{ needs.build.outputs.artifact-name }}"
```
The structure is `needs.<job-id>.outputs.<output-name>`.

**Hint 5:** The step `id` in the skeleton is used in two places — once where you define it (`id: my-step`) and once where you reference it (`${{ steps.my-step.outputs.value }}`). Both need to match exactly.
