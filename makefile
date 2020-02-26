#!/usr/bin/make -f

AP := ansible-playbook
TOWER_VERSION := 3.6.3-1

AG := "-e tower_version=$(TOWER_VERSION) -e tower_download=1"
AV := -vv
#AK := '--private_key=~/.vagrant.d/insecure_private_key'
AF := '-e tower_failback=1'

AI := inventory_ha_dr

.PHONY: roles

#####INFRA
tower-infra-destroy:
	cd $(AI); vagrant destroy -f

tower-infra-up:
	cd $(AI); vagrant up

##ANSIBLE
.PHONY: all test clean $(wildcard *.yml)

%:
	$(AP) $*.yml $(AG) $(AV) $(EF)

tower-dr-failback:
	@$(MAKE) tower-dr-failover EF=$(AF)

tower-ha-failback:
	@$(MAKE) tower-ha-failover EF=$(AF)

tower-orchestrate-full: tower-infra-up tower-setup tower-orchestrate-dr
	@echo "FINISHED TOWER INFRA + ORCHESTRATION"

tower-orchestrate-dr: tower-dr-standup tower-dr-failover tower-dr-failback tower-ha-failover tower-ha-failback
	@echo "FINISHED TOWER DR ORCHESTRATION"

tower-3.5:
	@$(MAKE) tower-orchestrate-full TOWER_VERSION=3.5.4-1

tower-3.6:
	@$(MAKE) tower-orchestrate-full TOWER_VERSION=3.6.3-1

set-el7:
	TOWER_EL_VERSION=el7
set-el8:
	TOWER_EL_VERSION=el8

tower-3.6-centos7: export VBOX=centos/7
tower-3.6-centos7: set-el7
	@$(MAKE) tower-3.6

tower-3.6-rh7: export VBOX=generic/rhel7
tower-3.6-rh7: set-el7
	@$(MAKE) tower-3.6
	
tower-3.6-centos8: export VBOX=centos/8
tower-3.6-centos8: set-el8
	@$(MAKE) tower-3.6

tower-3.5-el7: set-el7
	@$(MAKE) tower-3.5

tower-3.5-el8:
	@echo "not supported"