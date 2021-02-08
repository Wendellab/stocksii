#MUST HAVE FOR MODULES TO WORK
SHELL := /bin/bash

# Check that given variables are set and all have non-empty values,
# die with an error otherwise.
#
# Params:
#   1. Variable name(s) to test.
#   2. (optional) Error message to print.
var_required = \
	$(strip $(foreach 1,$1, \
		$(call __var_required,$1,$(strip $(value 2)))))
__var_required = \
	$(if $(value $1),, \
		$(error Undefined $1$(if $2, ($2))))

#########################################
####### Required Input Parameters #######
#########################################
#                    NAME     Description
$(call var_required, NAME,       Output Name)
$(call var_required, GENOME,     Input Genome)
$(call var_required, REFERENCE,  Reference Genome)
$(call var_required, CPUS,       Number of threads per task )

# Path to pipeline makefiles
pipeline := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

.PHONY: all
all: $(NAME).png


$(NAME).paf : $(REFERENCE) $(GENOME)
	ml singularity/3.5.2 minimap2 && \
	minimap2 -x asm5 -t $(CPUS) $^ > $@.tmp
	mv $@.tmp $@

$(NAME).png : $(NAME).paf
	ml r/4.0.2 && \
	Rscript $(pipeline)/pafCoordsDotPlotly.R -i $< \
		-o $(NAME) -m 20000 -x -s -t -l -p 12
