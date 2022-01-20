  {
    defaults = import ./base.nix;
    vgratarola = {
      deployment.targetHost = "192.168.100.244";

      boot.loader.grub.device = "/dev/sda";
      boot.loader.grub.version = 2;

      fileSystems = {
        "/" = {
          device = "/dev/disk/by-label/nixos";
          fsType = "ext4";
        };
      };

      networking.hostName = "vgratarola";
    };
  }
