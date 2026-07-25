#!/bin/sh

OUTPUT_FILE=$1

GIT_VERSION=$(git describe --tags --always --dirty 2>/dev/null || echo "unknown")
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

cat >"$OUTPUT_FILE" <<EOF
// AUTO-GENERATED FILE. DO NOT EDIT.
public enum BuildInfo {
    public static let version = "$GIT_VERSION"
    public static let buildDate = "$BUILD_DATE"
}
EOF
