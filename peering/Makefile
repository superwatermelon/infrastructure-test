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

ifndef INTERNAL_AWS_PROFILE
	$(error INTERNAL_AWS_PROFILE is undefined)
endif

ifndef INTERNAL_TFSTATE_BUCKET
	$(error INTERNAL_TFSTATE_BUCKET is undefined)
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
		-var test_tfstate_bucket=$(TFSTATE_BUCKET) \
		-var internal_aws_profile=$(INTERNAL_AWS_PROFILE) \
		-var internal_tfstate_bucket=$(INTERNAL_TFSTATE_BUCKET) \
		-out $(TFPLAN_PATH) \
		$(TERRAFORM_DIR)

.PHONY: apply
apply:
	$(TERRAFORM) apply \
		-no-color \
		$(TFPLAN_PATH)

.PHONY: destroy
destroy: check
	$(TERRAFORM) destroy \
		-no-color \
		-var test_tfstate_bucket=$(TFSTATE_BUCKET) \
		-var internal_aws_profile=$(INTERNAL_AWS_PROFILE) \
		-var internal_tfstate_bucket=$(INTERNAL_TFSTATE_BUCKET) \
		$(TERRAFORM_DIR)
