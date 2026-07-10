# Browserctl

Manage default browser on MacOS from the command line.

## Usage

Get current default browser:

```bash
browserctl get
```

List availble browsers:

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
- https://www.felixparadis.com/posts/how-to-set-the-default-browser-from-the-command-line-on-a-mac/#automatically-accept-the-prompt-with-applescript
