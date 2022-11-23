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
	eval '$(SCRIPTS)/create.sh $(realpath $(HW))'



.PHONY: overlay
overlay: $(VITIS_OVERLAY_BIT)
$(VITIS_OVERLAY_BIT): $(PFM_XPFM)
	@valid=0; \
	for o in $(OVERLAY_LIST); do \
		if [ "$$o" = "$(OVERLAY)" ]; then \
			valid=1; \
			break; \
		fi \
	done; \
	if [ "$$valid" -ne 1 ]; then \
		echo 'Invalid parameter OVERLAY=$(OVERLAY). Choose one of: $(OVERLAY_LIST)'; \
		exit 1; \
	fi; \
	echo 'Build $(OVERLAY) Vitis overlay using platform $(PFM)'; \
	$(MAKE) -C $(VITIS_OVERLAY_DIR) all PLATFORM=$(PFM_XPFM)

.PHONY: platform
platform: $(PFM_XPFM)
$(PFM_XPFM):
	@valid=0; \
	for p in $(PFM_LIST); do \
		if [ "$$p" = "$(PFM)" ]; then \
			valid=1; \
			break; \
		fi \
	done; \
	if [ "$$valid" -ne 1 ]; then \
		echo 'Invalid parameter PFM=$(PFM). Choose one of: $(PFM_LIST)'; \
		exit 1; \
	fi; \
	echo 'Create Vitis platform $(PFM)'; \
	$(MAKE) -C $(PFM_DIR) platform PLATFORM=$(PFM) VERSION=$(PFM_VER)

.PHONY: clean
clean:
	$(foreach o, $(OVERLAY_LIST), $(MAKE) -C $(VITIS_DIR)/$(o) clean;)
	$(foreach p, $(PFM_LIST), $(MAKE) -C $(PFM_DIR) clean PLATFORM=$(p) VERSION=$(PFM_VER);)
