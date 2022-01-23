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

  services.grafana = {
    enable = true;
    addr = "";
    port = 2112;
  };

  services.loki = {
    enable = true;
    configFile = ./loki.yml;
  };

  systemd.services.promtail = {
    description = "Promtail service for Loki";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = ''
        ${pkgs.grafana-loki}/bin/promtail --config.file ${./promtail.yml}
      '';
    };
  };

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
    openFirewall = true;
  };

  services.sonarr = {
    enable = true;
    group = config.services.jellyfin.group;
  };

  services.radarr = {
    enable = true;
    group = config.services.jellyfin.group;
  };

  services.bazarr = {
    enable = true;
    group = config.services.jellyfin.group;
  };
  # bazarr needs unrar
  nixpkgs.config.allowUnfree = true;

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
