# dotfiles

![License](https://img.shields.io/github/license/WingLim/dotfiles) ![Ubuntu 20.04](https://github.com/WingLim/dotfiles/workflows/Ubuntu/badge.svg?branch=main) ![MacOS](https://github.com/WingLim/dotfiles/workflows/MacOS/badge.svg)

WingLim's `.files`, auto config shell and some develop environment.

Inspired by [SukkaW/dotfiles](https://github.com/SukkaW/dotfiles)

## Usage

```bash
curl -o- https://raw.githubusercontent.com/WingLim/dotfiles/main/install.sh | bash
```

**Use CDN**
```bash
curl -o- https://cdn.jsdelivr.net/gh/WingLim/dotfiles@main/install.sh | bash
```

## Options

### `--novim`
Script will auto install [ThinkVim](https://github.com/hardcoreplayers/ThinkVim) to configuare neovim.

If you don't want to use this neovim configuration, use `--novim` to not install it.

### `--cdn`
**Only work WITHOUT `--novim`**
For using C/C++/ObjC LSP(Language Server Protocol) in neovim, script will download LLVM Pre-Built Binaries to compile and install [ccls](https://github.com/MaskRay/ccls).

Use `--cdn` to download LLVM Pre-Built Binaries from Tsinghua Mirror.

## WSL2

If you are using WSL2 Ubuntu, you can use below script to config `nameserver`

Default `nameserver` is `223.5.5.5`

```bash
curl -o- https://raw.githubusercontent.com/WingLim/dotfiles/main/wsl/set_nameserver.sh | bash
```

You can custom the `nameserver` like this:

```bash
curl -o- https://raw.githubusercontent.com/WingLim/dotfiles/main/wsl/set_nameserver.sh | bash "1.1.1.1"
```
