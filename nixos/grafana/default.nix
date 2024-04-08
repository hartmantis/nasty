{config, pkgs, agenix, variables, secrets, ...}: let
  vars = import variables;
in {
  environment.systemPackages = with pkgs; [
    grafana-agent
  ];

  age.secrets."grafana-logs-remote-write-url".file = "${secrets}/monitoring/grafana/logs_remote_write_url.age";
  age.secrets."grafana-logs-remote-write-username".file = "${secrets}/monitoring/grafana/logs_remote_write_username.age";
  age.secrets."grafana-logs-remote-write-password".file = "${secrets}/monitoring/grafana/logs_remote_write_password.age";
  age.secrets."grafana-metrics-remote-write-url".file = "${secrets}/monitoring/grafana/metrics_remote_write_url.age";
  age.secrets."grafana-metrics-remote-write-username".file = "${secrets}/monitoring/grafana/metrics_remote_write_username.age";
  age.secrets."grafana-metrics-remote-write-password".file = "${secrets}/monitoring/grafana/metrics_remote_write_password.age";
  age.secrets."grafana-traces-remote-write-endpoint".file = "${secrets}/monitoring/grafana/traces_remote_write_endpoint.age";
  age.secrets."grafana-traces-remote-write-username".file = "${secrets}/monitoring/grafana/traces_remote_write_username.age";
  age.secrets."grafana-traces-remote-write-password".file = "${secrets}/monitoring/grafana/traces_remote_write_password.age";

  services.grafana-agent.credentials = {
    LOGS_REMOTE_WRITE_URL = config.age.secrets."grafana-logs-remote-write-url".path;
    LOGS_REMOTE_WRITE_USERNAME = config.age.secrets."grafana-logs-remote-write-username".path;
    logs_remote_write_password = config.age.secrets."grafana-logs-remote-write-password".path;

    METRICS_REMOTE_WRITE_URL = config.age.secrets."grafana-metrics-remote-write-url".path;
    METRICS_REMOTE_WRITE_USERNAME = config.age.secrets."grafana-metrics-remote-write-username".path;
    metrics_remote_write_password = config.age.secrets."grafana-metrics-remote-write-password".path;

    TRACES_REMOTE_WRITE_ENDPOINT = config.age.secrets."grafana-traces-remote-write-endpoint".path;
    TRACES_REMOTE_WRITE_USERNAME = config.age.secrets."grafana-traces-remote-write-username".path;
    traces_remote_write_password = config.age.secrets."grafana-traces-remote-write-password".path;
  };

  services.grafana-agent.settings = {
    metrics.global = {
      remote_write = [{
        url = "\${METRICS_REMOTE_WRITE_URL}";
        basic_auth.username = "\${METRICS_REMOTE_WRITE_USERNAME}";
        basic_auth.password_file = "\${CREDENTIALS_DIRECTORY}/metrics_remote_write_password";
      }];

      scrape_interval = "60s";

      external_labels = {
        node = "${vars.hostName}.${vars.domain}";
      };
    };

    traces.configs = [{
      name = "default";

      remote_write = [{
        endpoint = "\${TRACES_REMOTE_WRITE_ENDPOINT}";
        basic_auth.username = "\${TRACES_REMOTE_WRITE_USERNAME}";
        basic_auth.password_file = "\${CREDENTIALS_DIRECTORY}/traces_remote_write_password";
      }];

      receivers.jaeger.protocols.thrift_compact = { };
    }];
  };

  services.grafana-agent.enable = true;
}
