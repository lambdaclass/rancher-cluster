.PHONY: reset help
.DEFAULT_GOAL := help

init: ## Create a Python virtual environment and install Ansible
	pipenv --three && pipenv install

prepare: ## Prepare nodes. Install Docker, disable swap and check for required kernel modules.
	pipenv run ansible-playbook -i ansible/inventory.ini ansible/prepare-cluster.yml --flush-cache

config: ## Create Rancher config.yml
	rke config

cluster: ## Install Kubernetes with Rancher
	rke up

reset: ## Remove Rancher installation
	rke remove

help: ## This screen :)
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
