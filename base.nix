{pkgs, lib, config, ...}:
{
  imports = [ ./qbittorrent.nix ];

  time.timeZone = "Americas/Argentina/Buenos_Aires";
  environment.systemPackages = with pkgs; [
    vim
    nmon
    htop
    mergerfs
    qbittorrent-nox
  ];

  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
  };

  # services.grafana = {
  #   enable = true;
  #   domain = "grafana.gratarola";
  #   port = 2112;
  # };
  # networking.firewall.allowedTCPPorts = [ config.services.grafana.port ];

  services.prometheus = {
    enable = true;
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9002;
      };
    };
    scrapeConfigs = [
      {
        job_name = "gratarola";
        static_configs = [{
          targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
        }];
      }
    ];
  };

  # mDNS, allows resolving gratarola.local
  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      domain = true;
      addresses = true;
    };
  };

  services.jellyfin = {
    enable = true;
  };

  services.tautulli.enable = true;

  services.sonarr = {
    enable = true;
    group = config.services.jellyfin.group;
  };

  services.radarr = {
    enable = true;
    group = config.services.jellyfin.group;
  };

  services.qbittorrent = {
    enable = true;
    group = config.services.jellyfin.group;
  };

  services.jackett = {
    enable = true;
  };

  services.ombi = {
    enable = true;
  };

}
