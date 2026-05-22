default: help

APP       ?=
COMPONENT ?=
TAG       ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo local)

.PHONY: help
help: ## list makefile targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: ## build a single component image — APP=<app> COMPONENT=<component> [TAG=<tag>]
	@test -n "$(APP)"       || (echo "error: APP is required.       Usage: make build APP=demo-app COMPONENT=frontend" && exit 1)
	@test -n "$(COMPONENT)" || (echo "error: COMPONENT is required. Usage: make build APP=demo-app COMPONENT=frontend" && exit 1)
	docker build \
		-t $(APP)-$(COMPONENT):$(TAG) \
		-f applications/$(APP)/src/$(COMPONENT)/Dockerfile \
		applications/$(APP)/src/$(COMPONENT)
