This devcontainer lets you run GitHub Actions workflows locally using [act](<https://github.com/nektos/act>), without pushing to GitHub. It's wired up to the [GitHub Local Actions](<https://marketplace.visualstudio.com/items?itemName=SanjulaGanepola.github-local-actions>) VS Code extension for a point-and-click run experience.

&#x2014;

\## Prerequisites

\### 1. Set \`GITHUB<sub>TOKEN</sub>\` in your host environment

Before opening the devcontainer, \`GITHUB<sub>TOKEN</sub>\` must be set as an environment variable on your ****host machine**** (not just in \`.env\`). This is because \`devcontainer.json\` reads it via \`${localEnv:GITHUB<sub>TOKEN</sub>}\` at container build time to bake the token into the image. If it's not present on the host when the container builds, \`gh\` inside the devcontainer will be unauthenticated.

Add it to your shell profile (e.g. \`~/.bashrc\`, \`~/.zshrc\`, or \`~/.profile\`):

\`\`\`bash export GITHUB<sub>TOKEN</sub>=ghp<sub>yourtoken</sub> \`\`\`

Then either restart your terminal or \`source\` the file before opening VS Code.

\### 2. Create a \`.env\` file

You also need a \`.env\` file in the repo root for act to pick up the token at runtime. Copy the example and fill it in:

\`\`\`bash cp .env.example .env \`\`\`

\`\`\`env GITHUB<sub>REPOSITORY</sub>=pol-onesource/nbit-github-actions GITHUB<sub>TOKEN</sub>=ghp<sub>yourtoken</sub> \`\`\`

\`GITHUB<sub>TOKEN</sub>\` must be a PAT with at minimum \`repo\` and \`read:org\` scopes, and SSO-authorised for the \`pol-onesource\` org. The token is used both by the devcontainer itself (for \`gh\` CLI calls during setup) and by act when it runs workflows.

&#x2014;

\## Architecture overview

There are two distinct Docker images in play and it's important not to confuse them.

\### 1. The devcontainer image (\`Dockerfile\`)

This is the environment you work **in** — your editor, terminal, and tooling. It's built from \`mcr.microsoft.com/devcontainers/base:ubuntu-24.04\` and adds:

-   ****act**** — the local GitHub Actions runner CLI, downloaded from the nektos releases page at build time. The binary is installed as \`act-binary\` and wrapped by a shell script at \`/usr/local/bin/act\` that prepends \`sudo\`, because act needs elevated permissions to manage Docker containers from inside the devcontainer.
-   ****gh**** — the GitHub CLI, installed from the official GitHub apt repo. Used both interactively and by workflows under test.
-   ****docker-ce-cli**** — the Docker **client** only (no daemon). The devcontainer has no Docker daemon of its own; instead the host's Docker socket is bind-mounted in at \`/var/run/docker.sock\`. This means \`docker\` commands inside the devcontainer talk to the host daemon transparently. The \`postStartCommand\` runs \`chmod 666\` on the socket so the \`vscode\` user can access it without sudo.

\### 2. The act runner image (\`Dockerfile.act-runner\`)

This is the environment your workflow steps run **inside** — act spins up a container from this image for each job. It's completely separate from the devcontainer.

The natural choice for this image is \`catthehacker/ubuntu:act-22.04\` — a lean (~600MB) Ubuntu 22.04 image designed specifically for act. However it doesn't include \`gh\`, which our workflows need. The \`full\` variant of the catthehacker image does include it, but weighs in at ~18GB which is not feasible on a development machine.

The solution is \`Dockerfile.act-runner\`: a thin layer on top of \`catthehacker/ubuntu:act-22.04\` that installs \`gh\` from the official GitHub CLI apt repo (rather than the Ubuntu apt repo, which ships a very old version). It also explicitly sets \`PATH\` and symlinks \`gh\` into \`/usr/local/bin\` to ensure it's findable regardless of how bash is invoked — act runs scripts with \`bash &#x2013;noprofile &#x2013;norc\`, which skips profile loading and can produce a stripped PATH if the image's ENV isn't handled carefully.

This image is built automatically when the devcontainer is created (see \`postCreateCommand\` below) and tagged as \`local/act-runner:latest\`.

&#x2014;

\## How the pieces connect

\`\`\` VS Code └── GitHub Local Actions extension └── invokes: act &#x2013;workflows &#x2026; &#x2013;job &#x2026; └── reads: ~/.actrc (copied from .actrc at container create time) └── -P ubuntu-latest=local/act-runner:latest └── &#x2013;env GITHUB<sub>REF</sub>=refs/heads/master └── &#x2013;pull=false (use local image, don't try to pull) └── &#x2013;reuse (keep runner container between runs for speed) └── spins up: local/act-runner:latest (via host Docker daemon) └── runs workflow steps inside that container \`\`\`

\### Why \`~/.actrc\` and not the project \`.actrc\`

act looks for its config file at \`~/.actrc\` in the home directory of the user running it, not in the project root. The project \`.actrc\` is source-controlled for consistency, but needs to be copied to \`~/.actrc\` to take effect. This happens automatically via \`postCreateCommand\`.

\### Why \`&#x2013;pull=false\`

By default act always attempts to pull the runner image from a registry before each run (\`forcePull=true\`). Since \`local/act-runner:latest\` doesn't exist in any registry, this would fail. \`&#x2013;pull=false\` tells act to use whatever is available locally.

\### Why \`&#x2013;env GITHUB<sub>REF</sub>=refs/heads/master\`

When act runs locally it detects \`GITHUB<sub>REF</sub>\` from the git state of your working copy. If your local HEAD is on a tag (e.g. \`refs/tags/v12.96.0\`), that tag ref gets passed into the workflow. The \`extract-branch\` step strips \`refs/heads/\` from the ref to get a branch name — which does nothing to a tag ref, so the full tag string gets passed to \`gh api repos/&#x2026;/branches/$BRANCH\`, which returns 404 because tags aren't branches.

Explicitly setting \`GITHUB<sub>REF</sub>=refs/heads/master\` overrides the git-detected value and gives the workflow a valid branch context. Use \`master\` because that's the default branch of \`pol-onesource/nbit-github-actions\`.

\### Why the event payload

The GitHub Local Actions extension passes \`&#x2013;eventpath ""\` explicitly, which means act has no event context by default. Some workflow steps behave differently (or fail) without it. The \`push.json\` payload file provides a minimal push event context — repository name and ref — and is selected in the extension's Settings panel under Payloads.

&#x2014;

\## First-time setup

1.  Ensure \`.env\` exists in the repo root (see Prerequisites above).
2.  Open the repo in VS Code and reopen in devcontainer when prompted.
3.  The \`postCreateCommand\` will run automatically — it copies \`.actrc\` to \`~/.actrc\` and builds the \`local/act-runner:latest\` image. This takes a minute or two on first run.
4.  In the GitHub Local Actions sidebar, go to Settings and ensure \`push.json\` is checked under Payloads.
5.  You're ready — click Run next to any workflow in the sidebar.

&#x2014;

\## Rebuilding the runner image

If you update \`Dockerfile.act-runner\` (e.g. to add another missing tool), rebuild with:

\`\`\`bash docker build &#x2013;no-cache -t local/act-runner:latest -f .devcontainer/Dockerfile.act-runner . \`\`\`

Then kill any reused runner container so act picks up the new image on the next run:

\`\`\`bash docker rm -f $(docker ps -a &#x2013;filter "ancestor=local/act-runner:latest" -q) \`\`\`

&#x2014;

\## Troubleshooting

****\`gh: command not found\` in workflow steps****

The runner container is stale from before \`gh\` was added to the image. Kill it:

\`\`\`bash docker rm -f $(docker ps -a &#x2013;filter "ancestor=local/act-runner:latest" -q) \`\`\`

Then re-run. If it persists, verify \`gh\` is actually in the image:

\`\`\`bash docker run &#x2013;rm local/act-runner:latest which gh \`\`\`

****\`pull access denied for local/act-runner\`****

\`&#x2013;pull=false\` is missing from \`~/.actrc\`. Check the file exists and contains the flag:

\`\`\`bash cat ~/.actrc \`\`\`

If it's missing or empty, re-copy it:

\`\`\`bash cp .actrc ~/.actrc \`\`\`

****\`Branch not found (HTTP 404)\` in the protected-branch step****

\`GITHUB<sub>REF</sub>\` is resolving to a tag ref instead of a branch name. Check \`~/.actrc\` contains:

\`\`\` &#x2013;env GITHUB<sub>REF</sub>=refs/heads/master \`\`\`

****Workflow is using \`catthehacker/ubuntu:act-22.04\` instead of \`local/act-runner:latest\`****

\`&#x2013;reuse\` is keeping an old container that was created before the \`-P\` flag was updated. Kill it:

\`\`\`bash docker rm -f $(docker ps -a &#x2013;filter "ancestor=catthehacker/ubuntu:act-22.04" -q) \`\`\`

****\`make: docker: No such file or directory\` during postCreateCommand****

The devcontainer image needs to be rebuilt to pick up the \`docker-ce-cli\` install layer. In VS Code: \`Ctrl+Shift+P\` → "Dev Containers: Rebuild Container".
