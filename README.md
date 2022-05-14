# Nix System Configurations

## Macbook

Steps:
- installed nix with --daemon
- installed nix-darwin
- flake init
- installed brew
- turned off brew analytics
- chsh -s /run/current-system/sw/bin/fish

How to install flake when flake support is disabled by default?
https://gist.github.com/jmatsushita/5c50ef14b4b96cb24ae5268dab613050

## Lenovo

WSL2 Ubuntu with `home-manager`, with a single-user nix install:

```
sh <(curl -L https://nixos.org/nix/install) --no-daemon
```

Initally apply config with

```
nix --extra-experimental-features "nix-command flakes" build .#homeConfigurations.rgruber.activationPackage
result/activate
```

and then

```
home-manager switch --flake .#rgruber
```
### Borders of the nixified MacBook

`nix-darwin` is only half the story when it comes to a declarative system
configuration.

- homebrew and mac app store programs
- setting up shell-related software which requires system-wide installations
  - gpg-agent
  - VS Code
  - shell itself
- fonts
- some development-related macos defaults
- bootstrapping home-manager
- managing `nix` and the nix daemon
