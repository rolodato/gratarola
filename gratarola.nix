{
  defaults = import ./base.nix;

  gratarola = {
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

  };
}
