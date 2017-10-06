SHELL = /bin/sh

TFPLAN_PATH = terraform.tfplan

TERRAFORM = terraform

TERRAFORM_DIR = terraform

.PHONY: default
default: load plan

.PHONY: check
check:
ifndef AWS_DEFAULT_REGION
	$(error AWS_DEFAULT_REGION is undefined)
endif

ifndef TFSTATE_BUCKET
	$(error TFSTATE_BUCKET is undefined)
endif

ifndef HOSTED_ZONE
	$(error HOSTED_ZONE is undefined)
endif

ifndef SWARM_MANAGER_KEY_PAIR
	$(error SWARM_MANAGER_KEY_PAIR is undefined)
endif

ifndef SWARM_WORKER_KEY_PAIR
	$(error SWARM_WORKER_KEY_PAIR is undefined)
endif

ifndef INTERNAL_TFSTATE_BUCKET
	$(error INTERNAL_TFSTATE_BUCKET is undefined)
endif

ifndef INTERNAL_AWS_PROFILE
	$(error INTERNAL_AWS_PROFILE is undefined)
endif

.PHONY: load
load: check
	$(TERRAFORM) init \
		-no-color \
		-backend=true \
		-input=false \
		-backend-config bucket=$(TFSTATE_BUCKET) \
		-backend-config region=$(AWS_DEFAULT_REGION) \
		$(TERRAFORM_DIR)

.PHONY: plan
plan: check
	$(TERRAFORM) plan \
		-no-color \
		-var swarm_manager_key_pair=$(SWARM_MANAGER_KEY_PAIR) \
		-var swarm_worker_key_pair=$(SWARM_WORKER_KEY_PAIR) \
		-var hosted_zone=$(HOSTED_ZONE) \
		-var internal_tfstate_bucket=$(INTERNAL_TFSTATE_BUCKET) \
		-var internal_aws_profile=$(INTERNAL_AWS_PROFILE) \
		-out $(TFPLAN_PATH) \
		$(TERRAFORM_DIR)

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
		-var swarm_worker_key_pair=$(SWARM_WORKER_KEY_PAIR) \
		-var hosted_zone=$(HOSTED_ZONE) \
		-var internal_tfstate_bucket=$(INTERNAL_TFSTATE_BUCKET) \
		-var internal_aws_profile=$(INTERNAL_AWS_PROFILE) \
		$(TERRAFORM_DIR)
