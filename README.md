# NASty

All the non-secret components I use to run my NAS.

This is a work in progress. I don't know NixOS. Do not trust anything in this
repo.

*There is destructive code in this repo. Do not use it or the ISO artifacts it
produces unless you want to wipe your root drive.*

Ultimate goal: to be able to boot my NAS from a custom ISO built by GitHub
actions and have it do a clean, unattended install of everything it needs to
run.

## Contents

### NixOS

Code to build a custom NixOS installer ISO that, when used to boot a system,
*will destroy all root drive data* and provision it with a fresh NixOS install
plus any NAS-specific goodies I choose to add.

Bootstrapping the system requires two USB keys:

1. An installer drive created from the ISO that this project generates as
   release artifacts
2. A drive with the desired SSH host keys on it to handle decrypting secrets

### TF

OpenTofu/Terraform configs for DNS and monitoring..
