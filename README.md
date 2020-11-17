# dotfiles

![License](https://img.shields.io/github/license/WingLim/dotfiles) ![Ubuntu](https://github.com/WingLim/dotfiles/workflows/Ubuntu/badge.svg?branch=main) ![MacOS](https://github.com/WingLim/dotfiles/workflows/MacOS/badge.svg)

WingLim's `.files`, auto config shell and some develop environment.

Test in WSL Ubuntu 20.04

Inspired by [SukkaW/dotfiles](https://github.com/SukkaW/dotfiles)

## Usage

```bash
curl -o- https://raw.githubusercontent.com/WingLim/dotfiles/main/install.sh | bash
```

If you are using WSL2 Ubuntu, you can use below script to config `nameserver`

Default `nameserver` is `223.5.5.5`

```bash
curl -o- https://raw.githubusercontent.com/WingLim/dotfiles/main/wsl/set_nameserver.sh | bash
```

You can custom the `nameserver` like this:

```bash
curl -o- https://raw.githubusercontent.com/WingLim/dotfiles/main/wsl/set_nameserver.sh | bash "1.1.1.1"
```
