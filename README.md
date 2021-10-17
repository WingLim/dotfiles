# dotfiles

![License](https://img.shields.io/github/license/WingLim/dotfiles) ![Ubuntu 20.04](https://github.com/WingLim/dotfiles/workflows/Ubuntu/badge.svg?branch=main) ![MacOS](https://github.com/WingLim/dotfiles/workflows/MacOS/badge.svg)

WingLim's `.files`, auto config shell and some develop environment.

Inspired by [SukkaW/dotfiles](https://github.com/SukkaW/dotfiles)

## Usage

```bash
curl -o- https://raw.githubusercontent.com/WingLim/dotfiles/main/install.sh | bash

# jsdelivr cdn
curl -o- https://cdn.jsdelivr.net/gh/WingLim/dotfiles@main/install.sh | bash
```

## Options

### `--noproxy`

Script will add `proxy` and `noproxy` function to `.zshrc` for user to use [Clash](https://github.com/Dreamacro/clash) as proxy.

Use `--noproxy` to remove these functions.

## WSL2

If you are using WSL2 Ubuntu, you can use below script to config `nameserver`

Default `nameserver` is `223.5.5.5`

```bash
curl -o- https://raw.githubusercontent.com/WingLim/dotfiles/main/wsl/set_nameserver.sh | bash

# jsdelivr cdn
curl -o- https://cdn.jsdelivr.net/gh/WingLim/dotfiles@main/wsl/set_nameserver.sh | bash
```

You can custom the `nameserver` like this:

```bash
curl -o- https://raw.githubusercontent.com/WingLim/dotfiles/main/wsl/set_nameserver.sh | bash "1.1.1.1"
```
