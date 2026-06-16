default: help

APP ?=
TAG ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo local)

.PHONY: help
help: ## list makefile targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: ## build an app image — APP=<app> [TAG=<tag>]
	@test -n "$(APP)" || (echo "error: APP is required. Usage: make build APP=demo-app" && exit 1)
	docker build \
		-t $(APP):$(TAG) \
		-f applications/$(APP)/src/Dockerfile \
		applications/$(APP)/src
