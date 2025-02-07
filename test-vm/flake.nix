{
  description = "Plymouth Test VM";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system}.default =
      (nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./test-vm.nix
          "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
        ];
      })
      .config
      .system
      .build
      .vm;
  };
}
