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
      "/var/media" = {
        device = "/mnt/ironwolf4000/media";
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
    services.tailscale = {
      enable = true;
    };
    services.openssh.openFirewall = true;
    networking.firewall = {
      # always allow traffic from your Tailscale network
      trustedInterfaces = [ "tailscale0" ];

      # allow the Tailscale UDP port through the firewall
      allowedUDPPorts = [ config.services.tailscale.port ];

      # allow you to SSH in over the public internet
      allowedTCPPorts = [ 22 ];
    };
    # create a oneshot job to authenticate to Tailscale
    systemd.services.tailscale-autoconnect = {
      description = "Automatic connection to Tailscale";

      # make sure tailscale is running before trying to connect to tailscale
      after = [ "network-pre.target" "tailscale.service" ];
      wants = [ "network-pre.target" "tailscale.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig.Type = "oneshot";

      script = with pkgs; ''
        # wait for tailscaled to settle
        sleep 2

        # check if we are already authenticated to tailscale
        status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
        if [ $status = "Running" ]; then # if so, then do nothing
          exit 0
        fi

        # otherwise authenticate with tailscale
        ${tailscale}/bin/tailscale up -authkey tskey-kL4mSj1CNTRL-qcw4Zr5xNnZLuS6ttt755
      '';
    };
  };
}
