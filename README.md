# Browserctl

Manage default browser on macOS from the command line.

[![CI](https://github.com/peter-bread/browserctl/actions/workflows/ci.yaml/badge.svg)](https://github.com/peter-bread/browserctl/actions/workflows/ci.yaml)

## Requirements

- macOS 13.0 (Ventura) or later

### Build-only

- Swift 5.9 or later

## Install

### Homebrew

```bash
brew install peter-bread/tap/browserctl
```

### GitHub Releases

Pre-built binaries are available via GitHub Releases.

You can also use the provided installation script:

```bash
curl -fsSL https://raw.githubusercontent.com/peter-bread/browserctl/refs/heads/main/scripts/install.sh | bash
```

This will install the `browserctl` binary and manpage to the `~/.local` prefix.

Optionally, set the `PREFIX` environment variable:

```bash
curl -fsSL https://raw.githubusercontent.com/peter-bread/browserctl/refs/heads/main/scripts/install.sh | PREFIX=/usr/local bash
```

This may require updating `MANPATH`.

### Build from Source

Build and install `browserctl`.

By default, the executable is installed to the prefix `~/.local`, meaning the
path to the executable is `~/.local/bin/browserctl`.

The `install-all` target will build and install both the binary and manpage.

```bash
git clone https://github.com/peter-bread/browserctl
cd browserctl
make install-all
```

For just the binary, use `make release && make install`.

To install to a different location, specify a prefix:

```bash
sudo make install PREFIX=/usr/local
```

## Usage

> [!TIP]
>
> For more information, be sure to use `browserctl help` and `browserctl help <subcommand>`.
>
> (Or `browserctl -h` and `browserctl <subcommand> -h`)

#### Get current default browser

```bash
browserctl get
```

#### List available browsers

```bash
browserctl list
```

For each of the above, you can use `--name-only` or `--id-only` to filter the
output data.

#### Set default browser

```bash
browserctl set <query>
```

The query must be an exact, case-insenstive match against one of, in order:

1. bundle ID
1. bundle display name
1. bundle name

For example, the following are equivalent:

```bash
browserctl set chrome             # name
browserctl set 'GooGLe ChrOme'    # display name
browserctl set com.google.Chrome  # id
```

Currently, there is no [support for fuzzy matching, suggestions or multiple matches](https://github.com/peter-bread/browserctl/issues/11).

#### Launch browser

```bash
# launch default browser
browserctl launch

# launch specified browser
browserctl launch <name|id>

# launch default browser and open url
browserctl launch --url <url>

# launch specified browser and open url
browserctl launch <name|id> --url <url>
```

### Shell Completion

You can generate shell completion with:

```bash
browserctl --generate-completion-script <shell>
```

where `shell` is one of `bash`, `zsh` or `fish`.

This is especially useful for the `browserctl set` command as it provides names and identifiers.

## Acknowledgements

- https://stackoverflow.com/questions/17528688/set-default-web-browser-via-command-line
- https://github.com/kerma/defaultbrowser
- https://github.com/jwbargsten/defbro
<!-- - https://www.felixparadis.com/posts/how-to-set-the-default-browser-from-the-command-line-on-a-mac/#automatically-accept-the-prompt-with-applescript -->
