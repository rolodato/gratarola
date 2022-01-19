let machine = import ./base.nix; in
  {
    gratarola = machine {
      deployment.targetHost = "192.168.100.121";
      networking.hostName = "gratarola";
      networking.interfaces.enp1s0.useDHCP = true;
    };
  }
