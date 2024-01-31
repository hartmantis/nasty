# NASty

All the non-secret things I use to run my NAS.

This is a work in progress. I'm a NixOS noob. Do not trust anything in this
repo.

*There is destructive code in the `nixos` directory. Do not use it or the ISO
artifacts it produces unless you want to wipe your root drive.*

Ultimate goal: to be able to boot my NAS from a custom ISO built by GitHub
actions and have it do a clean, unattended install of everything it needs to
run.

TBD: Lots of things. Need to learn how to get secrets onto the server after
install (e.g. a Plex login).

## Contents

### /nixos

Code to build a custom NixOS installer ISO that, when used to boot a system,
*will destroy all root drive data* and reprovision it with a fresh NixOS
install plus any NAS-specific goodies I choose to add.

Bootstrapping the system requires two USB keys:

1. An installer drive created from the ISOs that this project generates as
   release artifacts
2. A drive with the desired SSH host keys on it that will then be used to
   decrypt our various secrets

### /tf

OpenTofu/Terraform components; right now just DNS records.
