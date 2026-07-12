# Browserctl

Manage default browser on MacOS from the command line.

## Requirements

- MacOS 12.0 (Monterey) or later

### Build-only

- Swift 5.9 or later

## Install

> [!WARNING]
>
> Currently there are no super convenient ways to install.
>
> The two planned methods are:
>
> 1. My Homebrew tap
> 1. GitHUb Releases prebuilt binaries
>
> See [this issue](https://github.com/peter-bread/browserctl/issues/5).

### Build from Source

```bash
git clone https://github.com/peter-bread/browserctl
cd browserctl
make release
install -m 0755 ./.build/release/browserctl "$HOME"/.local/bin
```

> [!NOTE]
>
> There will be a [`make install`](https://github.com/peter-bread/browserctl/issues/10) at some point.

## Usage

Get current default browser:

```bash
browserctl get
```

List available browsers:

```bash
browserctl list
```

For each of the above, you can use `--name-only` or `--id-only` to filter the
output data.

Set new default browser:

```bash
browserctl set <bundle-id>
```

## Acknowledgements

- https://stackoverflow.com/questions/17528688/set-default-web-browser-via-command-line
- https://github.com/kerma/defaultbrowser
- https://github.com/jwbargsten/defbro
<!-- - https://www.felixparadis.com/posts/how-to-set-the-default-browser-from-the-command-line-on-a-mac/#automatically-accept-the-prompt-with-applescript -->
