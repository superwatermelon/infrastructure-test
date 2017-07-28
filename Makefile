DIR := ./terraform

SWARM_MANAGER_KEY_PAIR := swarm-manager
SWARM_WORKER_KEY_PAIR := swarm-worker
TFPLAN_PATH := terraform.tfplan
TFSTATE_PATH := terraform.tfstate

default: load plan

check:
ifndef TEST_HOSTED_ZONE
	$(error TEST_HOSTED_ZONE is undefined)
endif

load:
	terraform get $(DIR)

plan: check
	terraform plan \
		-no-color \
		-var swarm_manager_key_pair=$(SWARM_MANAGER_KEY_PAIR) \
		-var swarm_worker_key_pair=$(SWARM_WORKER_KEY_PAIR) \
		-var test_hosted_zone=$(TEST_HOSTED_ZONE) \
		-out $(TFPLAN_PATH) \
		-state $(TFSTATE_PATH) $(DIR)

keys:
	scripts/init-keys \
		--swarm-manager-key-pair $(SWARM_MANAGER_KEY_PAIR) \
		--swarm-worker-key-pair $(SWARM_WORKER_KEY_PAIR)

apply: keys
	terraform apply \
		-no-color \
		-state $(TFSTATE_PATH) $(TFPLAN_PATH)

destroy: check
	terraform destroy \
		-no-color \
		-var swarm_manager_key_pair=$(SWARM_MANAGER_KEY_PAIR) \
		-var swarm_worker_key_pair=$(SWARM_WORKER_KEY_PAIR) \
		-var test_hosted_zone=$(TEST_HOSTED_ZONE) \
		-state $(TFSTATE_PATH) $(DIR)

.PHONY: default load save plan keys apply destroy
