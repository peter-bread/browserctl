#!/bin/sh

OUTPUT_FILE=$1

# First try BROWSERCTL_VERSION environment variable, then fall back to git describe.
: "${BROWSERCTL_VERSION:=$(
  version=$(git describe --tags --always --dirty 2>/dev/null || echo "unknown")
  printf '%s' "${version#v}"
)}"

# TODO: Maybe validate BROWSERCTL_VERSION

BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

cat >"$OUTPUT_FILE" <<EOF
// AUTO-GENERATED FILE. DO NOT EDIT.
public enum BuildInfo {
    public static let version = "$BROWSERCTL_VERSION"
    public static let buildDate = "$BUILD_DATE"
}
EOF
