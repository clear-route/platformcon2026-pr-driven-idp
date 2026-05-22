default: help

.PHONY: help
help: ## list makefile targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: infra
infra: ## provision infra with terraform
	terraform -chdir=infra init -backend-config="key=infra-$(cluster)" -reconfigure
	terraform -chdir=infra $(action) \
		-var-file=vars/default.tfvars \
		-var-file=clusters/$(cluster).tfvars
