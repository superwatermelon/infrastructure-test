SWARM_MANAGER_KEY_PAIR := swarm-manager
SWARM_WORKER_KEY_PAIR := swarm-worker
AWS_REGION := eu-west-1

default: load plan

load:
	terraform get

plan:
	terraform plan \
		-var swarm_manager_key_pair=$(SWARM_MANAGER_KEY_PAIR) \
		-var swarm_worker_key_pair=$(SWARM_WORKER_KEY_PAIR)

keys:
	pip install -r requirements.txt
	AWS_DEFAULT_REGION=$(AWS_REGION) scripts/init-keys.py \
		--swarm-manager-key-pair $(SWARM_MANAGER_KEY_PAIR) \
		--swarm-worker-key-pair $(SWARM_WORKER_KEY_PAIR)

apply: keys
	terraform apply \
		-var swarm_manager_key_pair=$(SWARM_MANAGER_KEY_PAIR) \
		-var swarm_worker_key_pair=$(SWARM_WORKER_KEY_PAIR)

destroy:
	terraform destroy \
		-var swarm_manager_key_pair=$(SWARM_MANAGER_KEY_PAIR) \
		-var swarm_worker_key_pair=$(SWARM_WORKER_KEY_PAIR)

.PHONY: default load plan keys apply destroy
