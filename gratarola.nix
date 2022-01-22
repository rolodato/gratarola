{
  defaults = import ./base.nix;

  gratarola = {config, pkgs, ...}: {
    deployment.targetHost = "192.168.100.121";

    boot.loader.grub.device = "/dev/sda";
    boot.loader.grub.version = 2;

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-uuid/3bacbcd0-0312-41cf-8f5b-e1e09e7e5c99";
        fsType = "ext4";
      };
      "/mnt/ironwolf4000" = {
        device = "/dev/disk/by-uuid/fb9d852b-232f-449e-88b9-759f4541f515";
        options = [ "defaults" "nofail" ];
      };
      "/mnt/wd500" = {
        device = "/dev/disk/by-uuid/a03a1968-2acc-4f02-84e5-35e3e4612477";
        options = [ "defaults" "nofail" ];
      };
      "/var/media" = {
        device = "/mnt/ironwolf4000/media:/mnt/wd500/media";
        fsType = "fuse.mergerfs";
        options = [
          "allow_other"
          "use_ino"
          "cache.files=partial"
          "dropcacheonclose=true"
          "category.create=mfs"
        ];
        noCheck = true;
      };
    };

    swapDevices = [ { device = "/dev/disk/by-uuid/314e865e-cd37-4765-bcff-fb7c88f71027"; } ];

    networking = {
      hostName = "gratarola";
      interfaces.enp1s0 = {
        useDHCP = true;
        wakeOnLan.enable = true;
      };
    };

    # Sleep when power button is pressed
    services.logind.extraConfig = ''
      HandlePowerKey=suspend
    '';

    # Tailscale VPN for static DNS and access from WAN
    # Remember to log in with `tailscale up`
    services.tailscale = {
      enable = true;
    };
    services.openssh.openFirewall = true;
    networking.firewall = {
      # always allow traffic from your Tailscale network
      trustedInterfaces = [ "tailscale0" ];

      # allow the Tailscale UDP port through the firewall
      allowedUDPPorts = [ config.services.tailscale.port ];
    };

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "gratarola" = {
          locations."/".proxyPass = "http://localhost:${toString config.services.ombi.port}/";
        };
      };
    };
    networking.firewall.allowedTCPPorts = [ 80 ];
  };
}
