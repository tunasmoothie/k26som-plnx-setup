CP = cp -f
SHELL := /bin/bash
PWD = $(shell readlink -f .)

SCRIPTS = $(PWD)/scripts

PLNX_PROJ = $(PWD)/plnx_project
VIVADO_PROJ = $(PWD)/plnx_project/hardware/


.PHONY: help
help:
	@echo ''
	@echo 'MAKE SURE TO SOURCE "env.sh" BEFORE PROCEEDING'
	@echo ''
	@echo 'Usage:'
	@echo ''
	@echo '  make create VP=<path>'
	@echo '    Create the Petalinux project folder'
	@echo ''
	@echo '    VP: Specfiy a Vivado project to initialize Petalinux project with.'
	@echo "        The Vivado project will be copied into 'plnx_build/hardware'."
	@echo ''
	@echo '  make update-hw HW=<path>'
	@echo '    Update Petalinux project XSA.'
	@echo ''
	@echo '    HW: Location of XSA file.'
	@echo ''
	@echo '  make platform PFM=<val> JOBS=<n>'
	@echo '    Build the Vitis platform.'
	@echo ''
	@echo '    Valid options for PFM: ${PFM_LIST}'
	@echo '    JOBS: optional param to set number of synthesis jobs (default 8)'
	@echo ''
	@echo '  make clean'
	@echo '    Clean runs'
	@echo ''


.PHONY: create
create:
ifeq ($(VP),)
	$(error No Vivado project specified)
endif
	eval '$(SCRIPTS)/create.sh $(realpath $(VP))'
VIVADO_PROJ := $(VP)


.PHONY: update-hw
update-hw:
	eval '$(SCRIPTS)/update-hw.sh $(realpath $(HW))'


.PHONY: clean
clean:
	$(foreach p, $(PFM_LIST), $(MAKE) -C $(PFM_DIR) clean PLATFORM=$(p) VERSION=$(PFM_VER);)
