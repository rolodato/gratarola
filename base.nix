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
  networking.firewall.allowedTCPPorts = [ config.services.tautulli.port ];

  services.sonarr = {
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

}
