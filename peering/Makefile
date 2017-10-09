SHELL = /bin/sh

TFPLAN_PATH = terraform.tfplan

TERRAFORM = terraform

TERRAFORM_DIR = terraform

.PHONY: default
default: load plan

.PHONY: load
load:
	$(TERRAFORM) init \
		-no-color \
		-backend=true \
		-input=false \
		-backend-config=backend.hcl

.PHONY: plan
plan:
	$(TERRAFORM) plan \
		-no-color \
		-out $(TFPLAN_PATH)

.PHONY: apply
apply:
	$(TERRAFORM) apply \
		-no-color \
		$(TFPLAN_PATH)
	scripts/associate-vpc

.PHONY: destroy
destroy:
	$(TERRAFORM) destroy \
		-no-color
