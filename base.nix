{ pkgs, lib, config, ... }:
{
  environment.systemPackages = with pkgs; [
    vim
    nmon
    htop
    mergerfs
    file
    wget
    zulu
  ];

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_port = 2112;
        http_addr = "";
      };
    };
  };

  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;
      server = {
        http_listen_port = 3100;
      };

      common = {
        path_prefix = "/tmp/loki";
        storage = {
          filesystem = {
            chunks_directory = "/tmp/loki/chunks";
            rules_directory = "/tmp/loki/rules";
          };
        };
        replication_factor = 1;
        ring = {
          instance_addr = "127.0.0.1";
          kvstore = {
            store = "inmemory";
          };
        };
      };

      schema_config = {
        configs = [
          {
            from = "2020-10-24";
            store = "boltdb-shipper";
            object_store = "filesystem";
            schema = "v11";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];
      };
    };
  };

  services.promtail = {
    configuration = {
      server = {
        http_listen_port = 28183;
        grpc_listen_port = 0;
      };
      positions = {
        filename = "/tmp/positions.yaml";
      };
      clients = [{
        url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push";
      }];
      scrape_configs = [{
        job_name = "journal";
        journal = {
          max_age = "12h";
          labels = {
            job = "systemd-journal";
            host = config.networking.hostName;
          };
        };
        relabel_configs = [{
          source_labels = [ "__journal__systemd_unit" ];
          target_label = "unit";
        }];
      }];
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
    # scrapeConfigs = [
    #   {
    #     job_name = "gratarola";
    #     static_configs = [{
    #       targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
    #     }];
    #   }
    # ];
  };

  users.groups.media = { };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    group = "media";
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

  services.prowlarr = {
    enable = true;
  };

  services.transmission = {
    enable = true;
    group = config.services.jellyfin.group;
    settings = {
      download-dir = "/var/media/.downloads";
      download-queue-size = 50;
      idle-seeding-limit-enabled = true;
      idle-seeding-limit = 1440;
      peer-limit-global = 1000;
      max-peers-global = 1000;
      peer-limit-per-torrent = 100;
      ratio-limit = 2;
      ratio-limit-enabled = true;
      rpc-whitelist-enabled = false;
      rpc-bind-address = "0.0.0.0";
      rpc-host-whitelist-enabled = false;
    };
    openPeerPorts = true;
  };

  services.jackett = {
    enable = true;
  };

  services.ombi = {
    enable = true;
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "gratarola" = {
        locations."/".proxyPass = "http://127.0.0.1:${toString config.services.ombi.port}/";
      };
    };
  };
  networking.firewall.allowedTCPPorts = [ 80 ];
  system.stateVersion = "22.11";
}
