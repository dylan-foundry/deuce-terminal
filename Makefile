all: build

.PHONY: build clean

UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
  DYLAN_COMPILER=OPEN_DYLAN_TARGET_PLATFORM=x86_64-darwin dylan-compiler
else
  DYLAN_COMPILER=dylan-compiler
endif

SOURCES = $(wildcard deuce-terminal/*.dylan) \
          $(wildcard standalone/*.dylan) \
          $(wildcard terminal-ui/*.dylan) \
          $(wildcard terminal/*.dylan) \
          $(wildcard */*.lid)

build: $(SOURCES)
	$(DYLAN_COMPILER) -build dt

clean:
	rm -rf _build/build/dt
	rm -rf _build/lib/*dt*
	rm -rf _build/bin/dt*
	rm -rf _build/lib/*terminal*
	rm -rf _build/build/deuce-terminal
	rm -rf _build/build/terminal
	rm -rf _build/build/terminal-ui
