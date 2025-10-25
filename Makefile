.PHONY: debug release

debug: Package.swift Sources/browserctl.swift
	swift build

release: Package.swift Sources/browserctl.swift
	swift build -c release
