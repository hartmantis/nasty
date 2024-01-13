# NASty

All the non-secret things I use to run my NAS.

This is a work in progress. I'm a NixOS noob. Do not trust anything in this
repo.

*There is destructive code in the `nixos` directory. Do not use it or the ISO
artifacts it produces unless you want to wipe your root drive.

## Contents

### /nixos

Code to build a custom NixOS installer ISO that, when used to boot a system,
*will destroy all root drive data* and reprovision it with a fresh NixOS
install plus any NAS-specific goodies I choose to add.

### /tf

OpenTofu/Terraform components; right now just DNS records.
