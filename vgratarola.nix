let machine = import ./base.nix; in
  {
    vgratarola = machine {
      deployment.targetHost = "192.168.100.244";
      networking.hostName = "vgratarola";
    };
  }
