{config, pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];

  services.jellyfin = {
    enable = true;
    # TODO: Set up a reverse proxy with TLS.
    openFirewall = true;
  };
}
