TARGETS = package

.PHONY: $(TARGETS)

all:
	$(error Valid targets are: $(TARGETS))

package:
	stdbuf -o0 conda build --error-overlinking recipe 2>&1
