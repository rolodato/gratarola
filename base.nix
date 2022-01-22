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
    openFirewall = true;
    managePlugins = false;
  };

  services.tautulli.enable = true;
  networking.firewall.allowedTCPPorts = [ config.services.tautulli.port 80 ];

  services.sonarr = {
    enable = true;
    group = "plex";
    openFirewall = true;
  };

  services.radarr = {
    enable = true;
    group = "plex";
    openFirewall = true;
  };

  services.qbittorrent = {
    enable = true;
    openFirewall = true;
  };

  services.jackett = {
    enable = true;
    openFirewall = true;
  };

  services.ombi = {
    enable = true;
    openFirewall = true;
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts."gratarola" = {
      locations."/".proxyPass = "http://localhost:${toString config.services.ombi.port}";
    };
  };

}
