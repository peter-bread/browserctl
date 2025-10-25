.PHONY: all debug release clean

all: debug

debug: Package.swift Sources/browserctl.swift
	swift build

release: Package.swift Sources/browserctl.swift
	swift build -c release

clean:
	rm -rf .build
