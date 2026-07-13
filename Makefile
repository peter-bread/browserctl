.PHONY: all debug release clean install

all: debug

debug:
	swift build

release:
	swift build -c release

# TODO: Replace with `swift package clean`?
clean:
	rm -rf .build


PREFIX ?= /usr/local

install:
	install -m 0755 ./.build/release/browserctl $(PREFIX)/bin
