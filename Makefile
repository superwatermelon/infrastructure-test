SWARM_MANAGER_KEY_PAIR := swarm-manager
SWARM_WORKER_KEY_PAIR := swarm-worker
TFPLAN_PATH := terraform.tfplan
TFSTATE_PATH := terraform.tfstate

default: load plan

check:
ifndef HOSTED_ZONE
	$(error HOSTED_ZONE is undefined)
endif

load:
	terraform init \
		-backend=true \
		-input=false \
		-backend-config bucket=$(TFSTATE_BUCKET) \
		-backend-config region=$(AWS_DEFAULT_REGION)

plan: check
	terraform plan \
		-no-color \
		-var swarm_manager_key_pair=$(SWARM_MANAGER_KEY_PAIR) \
		-var swarm_worker_key_pair=$(SWARM_WORKER_KEY_PAIR) \
		-var hosted_zone=$(HOSTED_ZONE) \
		-out $(TFPLAN_PATH)

keys:
	KEY_PAIR=$(SWARM_MANAGER_KEY_PAIR) scripts/init-keys > $(SWARM_MANAGER_KEY_PAIR).key
	KEY_PAIR=$(SWARM_WORKER_KEY_PAIR) scripts/init-keys > $(SWARM_WORKER_KEY_PAIR).key

apply: keys
	terraform apply \
		-no-color \
		-state $(TFSTATE_PATH) $(TFPLAN_PATH)

destroy: check
	terraform destroy \
		-no-color \
		-var swarm_manager_key_pair=$(SWARM_MANAGER_KEY_PAIR) \
		-var swarm_worker_key_pair=$(SWARM_WORKER_KEY_PAIR) \
		-var hosted_zone=$(HOSTED_ZONE)

.PHONY: default load save plan keys apply destroy
