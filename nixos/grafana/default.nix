{config, pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    grafana-agent
  ];
}
