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

          src = ./src;

          nativeBuildInputs = [pkgs.gnused];

          installPhase = ''
            runHook preInstall

            mkdir -p $out/share/plymouth/themes/serpentine
            cp -r $src/* $out/share/plymouth/themes/serpentine/

            # Fix paths in plymouth theme files
            for file in $out/share/plymouth/themes/serpentine/*.plymouth; do
              sed -i "s@/usr/@$out/@" $file
            done

            runHook postInstall
          '';

          meta = {
            description = "Serpentine Systems Plymouth Theme";
            longDescription = ''
              A monochrome Plymouth theme for Serpentine Systems featuring
              an animation with rotating rings and text.
            '';
            platforms = pkgs.lib.platforms.linux;
          };
        };

        # NixOS module for easy theme installation
        nixosModules.default = {
          config,
          lib,
          pkgs,
          ...
        }: {
          boot.plymouth = {
            enable = true;
            theme = "serpentine-rings";
            themePackages = [self.packages.${system}.default];
          };

          environment.systemPackages = [self.packages.${system}.default];
        };

        # Development shell
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            plymouth
            processing
          ];

          shellHook = ''
            echo "Plymouth Theme Development Environment"
            echo ""
            echo "Theme can be built with:"
            echo "  nix build"
            echo ""
            echo "Install in your NixOS configuration by importing this flake's nixosModules.default"
            echo ""
          '';
        };
      }
    );
}
