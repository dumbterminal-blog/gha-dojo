ACT_RUNNER_IMAGE := local/act-runner:latest
ACT_RUNNER_DOCKERFILE := .devcontainer/Dockerfile.act-runner

.PHONY: act-runner
act-runner: ## Build the local act runner image
	docker build -t $(ACT_RUNNER_IMAGE) -f $(ACT_RUNNER_DOCKERFILE) .
	@echo "Built $(ACT_RUNNER_IMAGE)"
