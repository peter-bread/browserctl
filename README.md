# Browserctl

Manage default browser on macOS from the command line.

## Requirements

- macOS 13.0 (Ventura) or later

### Build-only

- Swift 5.9 or later

## Install

> [!WARNING]
>
> Currently there are no super convenient ways to install.
>
> The two planned methods are:
>
> 1. My [Homebrew tap](https://github.com/peter-bread/homebrew-tap)
> 1. GitHub Releases (prebuilt binaries)
>
> See [this issue](https://github.com/peter-bread/browserctl/issues/5).

### Build from Source

Build and install `browserctl`.

By default, the executable is installed to `/usr/local/bin`, which will require
`sudo`.

```bash
git clone https://github.com/peter-bread/browserctl
cd browserctl
make release
sudo make install
```

To install to a different location, specify a prefix:

```bash
make install PREFIX=$HOME/.local
```

The executable will be installed to `<PREFIX>/bin`.

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
