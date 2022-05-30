# Nix System Configurations

## NixOS VMs

### Bootstrapping process

GitHub Actions build a qcow2 base image that can be imported in Synology
Virtual Machine Manager as Disk Image.

To import:
- Configure as desired
- As Disk use the included 10GB disk from qcow with virtio and do not provision a new disk. Autoresizing is enabled
  on boot so the disk can be resized later on.
- Before booting the VM for the first time is a good time to make the storage
  bigger
- Start VM

After being imported, the machines can be started and remotely
configured with `deploy-rs` after networking is sorted out so that
the machines are reachable under the hostnames `deploy-rs` uses.
By default, the qcow2 image acquires IP addresses by means of DHCP.
The preferred method of setting up networking are DHCP reservations, because
the MAC addresses are unique per imported VM.

Possibilities for bootstrapping `deploy-rs` configured machines in clouds
has yet to be explored.


## Macbook

Steps:
- installed nix with --daemon
- installed nix-darwin
- flake init
- installed brew
- turned off brew analytics
- chsh -s /run/current-system/sw/bin/fish
- ln -s /usr/local/opt/emacs-plus/Emacs.app /Applications/Emacs.app

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
e
change shell with

```
chsh -s /home/rgruber/.nix-profile/bin/fish
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
