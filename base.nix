args@{...}: {pkgs, lib, config, ...}:
  {
    time.timeZone = "Americas/Argentina/Buenos_Aires";
    networking.hostName = "gratarola";
    fileSystems."/" =
      { device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };
    boot.loader.grub.device = "/dev/sda";
    boot.loader.grub.version = 2;
    swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];
    nixpkgs.config.allowUnfree = true;
    environment.systemPackages = with pkgs; [
      vim
      nmon
      htop
    ];

    services.openssh = {
      enable = true;
      permitRootLogin = "yes";
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

    services.plex = {
      enable = true;
      openFirewall = true;
      managePlugins = false;
    };

    services.nginx = {
      enable = true;
      virtualHosts."plex.${config.networking.hostName}.local" = {
        root = "/var/lib/plex";
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/media 0755 ${config.services.plex.user} ${config.services.plex.group}"
      "d /var/media/TV 0755 ${config.services.plex.user} ${config.services.plex.group}"
      "d /var/media/Movies 0755 ${config.services.plex.user} ${config.services.plex.group}"
    ];

  } // args
