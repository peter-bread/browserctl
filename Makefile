# ========== BUILD ==========

.PHONY: all debug release clean

BUILD    = ./.build
BUILDMAN = ./man

all: debug

debug:
	swift build

release:
	swift build -c release

# TODO: Replace with `swift package clean`?
clean:
	rm -rf $(BUILD)


# ========== INSTALLATION ==========

.PHONY: install generate-manpage install-manpage install-all

# TODO: Should PREFIX be changed to something that doesn't require sudo,
# for example $(HOME)/.local
PREFIX ?= /usr/local
BIN     = $(PREFIX)/bin
MAN     = $(PREFIX)/share/man

install:
	install -d $(BIN)
	install -m 0755 $(BUILD)/release/browserctl $(BIN)

generate-manpage:
	swift package plugin generate-manual
	mkdir -p $(BUILDMAN)
	cp $(BUILD)/plugins/GenerateManual/outputs/browserctl/browserctl.1 $(BUILDMAN)

install-manpage: generate-manpage
	install -d $(MAN)/man1
	install $(BUILDMAN)/browserctl.1 $(MAN)/man1

install-all: release generate-manpage install install-manpage
