{pkgs, lib, config, ...}:
{
  imports = [ ./qbittorrent.nix ];
  time.timeZone = "Americas/Argentina/Buenos_Aires";
  nixpkgs.config.allowUnfree = true;
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

  # Sleep when power button is pressed
  services.logind.extraConfig = ''
    HandlePowerKey=suspend
  '';

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
  services.tautulli.enable = true;
  networking.firewall.allowedTCPPorts = [ config.services.tautulli.port ];

  services.sonarr = {
    enable = true;
    openFirewall = true;
  };

  services.qbittorrent = {
    enable = true;
    # group = "media";
    openFirewall = true;
  };
}
