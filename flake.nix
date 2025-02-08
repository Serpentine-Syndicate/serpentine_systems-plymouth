{
  description = "Serpentine Systems Plymouth Theme";

  outputs = inputs: {
    nixosModules.default = ./modules.nix;
  };
}
