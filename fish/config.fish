if status is-interactive
    # Commands to run in interactive sessions can go here
end
# Homebrew
if test (uname -m) = "arm64"
    eval (/opt/homebrew/brew shellenv)
else
    eval (/usr/local/bin/brew shellenv)
end

# z.lua https://github.com/skywind3000/z.lua
source (lua $HOME/.z/z.lua --init fish | psub)

# Starship https://starship.rs
fish_add_path "$HOME/.starship/bin"
starship init fish | source

# Deno
fish_add_path "$HOME/.deno/bin"

# asdf https://github.com/asdf-vm/asdf
source "$HOME/.asdf/asdf.fish"
