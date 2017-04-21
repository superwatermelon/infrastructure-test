SWARM_MANAGER_KEY_PAIR := swarm-manager
SWARM_WORKER_KEY_PAIR := swarm-worker
AWS_REGION := eu-west-1

default: load plan

load:
	scripts/pull-state
	terraform get

save:
	scripts/push-state

plan:
	terraform plan \
		-var swarm_manager_key_pair=$(SWARM_MANAGER_KEY_PAIR) \
		-var swarm_worker_key_pair=$(SWARM_WORKER_KEY_PAIR)

keys:
	AWS_DEFAULT_REGION=$(AWS_REGION) scripts/init-keys \
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

.PHONY: default load save plan keys apply destroy
