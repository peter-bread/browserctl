.PHONY: all debug release clean

all: debug

debug:
	swift build

release:
	swift build -c release

clean:
	rm -rf .build
