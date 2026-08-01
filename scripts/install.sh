#!/usr/bin/env bash

set -Eeuo pipefail

if [[ $(uname -s) != "Darwin" ]]; then
  echo "Warning: browserctl only works on macOS" >&2
fi

: "${PREFIX:=$HOME/.local}"

echo "PREFIX: $PREFIX"

maybe-sudo() {
  if [[ $PREFIX == /usr/* ]]; then
    sudo "$@"
  else
    "$@"
  fi
}

TAG=$(curl -s https://api.github.com/repos/peter-bread/browserctl/releases/latest |
  grep '"tag_name"' |
  cut -d '"' -f4)

echo "Latest tag: $TAG"

if [[ -z $TAG ]]; then
  echo "Error: tag is empty" >&2
  exit 1
fi

echo "Creating temporary directory..."

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' exit

echo "Created temporary directory: $TMP"

echo "Changing to $TMP"

cd "$TMP" || exit

VERSION="${TAG#v}"

PACKAGE=browserctl-$VERSION
TARBALL=$PACKAGE.tar.gz
TARBALL_URL=https://github.com/peter-bread/browserctl/releases/download/$TAG/$TARBALL

echo "Downloading $TARBALL from $TARBALL_URL..."

curl -fsSLO "$TARBALL_URL"

echo "Extracting $TARBALL..."

tar xzf "$TARBALL"

if [[ ! -d $PACKAGE ]]; then
  echo "Error: something went wrong"
  exit 1
fi

echo "Installing from $PACKAGE to $PREFIX..."

maybe-sudo install -d "$PREFIX"/bin
maybe-sudo install -m 755 "$PACKAGE"/bin/browserctl "$PREFIX"/bin

maybe-sudo install -d "$PREFIX"/share/man/man1
maybe-sudo install -m 644 "$PACKAGE"/share/man/man1/browserctl.1 "$PREFIX"/share/man/man1

echo "Installed browserctl $VERSION (tag: $TAG) to $PREFIX"
