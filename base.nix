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
    managePlugins = false;
  };

  services.tautulli.enable = true;

  services.sonarr = {
    enable = true;
    group = "plex";
  };

  services.radarr = {
    enable = true;
    group = "plex";
  };

  services.qbittorrent = {
    enable = true;
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
    virtualHosts."gratarola" = {
      locations."/".proxyPass = "http://localhost:${toString config.services.ombi.port}";
    };
  };
  networking.firewall.allowedTCPPorts = [ 80 ];

}
