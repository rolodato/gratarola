let
  machine = import ./base.nix;
in
  machine {
    networking.hostName = "vgratarola";
  }
