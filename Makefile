SHELL = /bin/sh

TFPLAN_PATH = terraform.tfplan

TERRAFORM = terraform

TERRAFORM_DIR = terraform

.PHONY: default
default: load plan

.PHONY: check
check:
ifndef SWARM_MANAGER_KEY_PAIR
	$(error SWARM_MANAGER_KEY_PAIR is undefined)
endif

ifndef SWARM_WORKER_KEY_PAIR
	$(error SWARM_WORKER_KEY_PAIR is undefined)
endif

.PHONY: load
load: check
	$(TERRAFORM) init \
		-no-color \
		-backend=true \
		-backend-config=backend.hcl \
		-input=false

.PHONY: plan
plan: check
	$(TERRAFORM) plan \
		-no-color \
		-var swarm_manager_key_pair=$(SWARM_MANAGER_KEY_PAIR) \
		-var swarm_worker_key_pair=$(SWARM_WORKER_KEY_PAIR) \
		-out $(TFPLAN_PATH)

.PHONY: keys
keys: check
	KEY_PAIR=$(SWARM_MANAGER_KEY_PAIR) scripts/init-key
	KEY_PAIR=$(SWARM_WORKER_KEY_PAIR) scripts/init-key

.PHONY: apply
apply: keys
	$(TERRAFORM) apply \
		-no-color \
		$(TFPLAN_PATH)

.PHONY: destroy
destroy: check
	$(TERRAFORM) destroy \
		-no-color \
		-var swarm_manager_key_pair=$(SWARM_MANAGER_KEY_PAIR) \
		-var swarm_worker_key_pair=$(SWARM_WORKER_KEY_PAIR)
