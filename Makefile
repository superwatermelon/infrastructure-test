SWARM_MANAGER_KEY_PAIR := swarm-manager
SWARM_WORKER_KEY_PAIR := swarm-worker
TFPLAN_PATH := terraform.tfplan
TFSTATE_PATH := terraform.tfstate

default: load plan

load:
	terraform get

plan:
	terraform plan \
		-var swarm_manager_key_pair=$(SWARM_MANAGER_KEY_PAIR) \
		-var swarm_worker_key_pair=$(SWARM_WORKER_KEY_PAIR) \
		-out $(TFPLAN_PATH) \
		-state $(TFSTATE_PATH)

keys:
	scripts/init-keys \
		--swarm-manager-key-pair $(SWARM_MANAGER_KEY_PAIR) \
		--swarm-worker-key-pair $(SWARM_WORKER_KEY_PAIR)

apply: keys
	terraform apply -state $(TFSTATE_PATH) $(TFPLAN_PATH)

destroy:
	terraform destroy \
		-var swarm_manager_key_pair=$(SWARM_MANAGER_KEY_PAIR) \
		-var swarm_worker_key_pair=$(SWARM_WORKER_KEY_PAIR) \
		-state $(TFSTATE_PATH)

.PHONY: default load save plan keys apply destroy
