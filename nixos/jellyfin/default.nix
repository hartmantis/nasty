{config, pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];

  imports = [
    ./config.nix
    ./monitoring.nix
  ];

  services.jellyfin = {
    enable = true;
  };
}
