{
  description = "Serpentine Systems Plymouth Theme";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "plymouth-theme-serpentine";
          version = "0.1.0";

          src = ./.;

          buildInputs = with pkgs; [
            plymouth
          ];

          installPhase = ''
            mkdir -p $out/share/plymouth/themes/serpentine
            cp -r src/* $out/share/plymouth/themes/serpentine/
            cp -r resources/* $out/share/plymouth/themes/serpentine/
          '';
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            plymouth
          ];
        };
      }
    );
}
