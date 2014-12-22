all: build

.PHONY: build clean

UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
  DYLAN_COMPILER=OPEN_DYLAN_TARGET_PLATFORM=x86_64-darwin dylan-compiler
else
  DYLAN_COMPILER=dylan-compiler
endif

terminal/tickit.dylan: terminal/tickit.intr $(wildcard terminal/libtickit/tickit*.h)
	melange -Tc-ffi -Iterminal/libtermkey -Iterminal/libtickit terminal/tickit.intr terminal/tickit.dylan

# We explicitly add tickit.dylan to the SOURCES in case
# a melange run failed which would have deleted the file.
SOURCES = $(wildcard deuce-terminal/*.dylan) \
          $(wildcard standalone/*.dylan) \
          $(wildcard terminal-ui/*.dylan) \
          $(wildcard terminal/*.dylan) \
          $(wildcard */*.lid) \
          terminal/tickit.dylan

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
