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
        packages.default = pkgs.stdenvNoCC.mkDerivation {
          pname = "plymouth-theme-serpentine-systems";
          version = "0.1.0";

          src = ./serpentine-systems;

          nativeBuildInputs = with pkgs; [
            gnused
            plymouth
          ];

          dontBuild = true;

          installPhase = ''
            runHook preInstall

            # Create theme directory
            mkdir -p $out/share/plymouth/themes/serpentine-systems

            # Copy theme files
            cp -r * $out/share/plymouth/themes/serpentine-systems/

            # Fix paths in plymouth theme files
            substituteInPlace $out/share/plymouth/themes/serpentine-systems/serpentine-systems.plymouth \
              --replace-fail "/usr/" "$out/"

            # Ensure correct permissions
            chmod -R 755 $out/share/plymouth/themes/serpentine-systems

            runHook postInstall
          '';

          meta = {
            description = "Serpentine Systems Plymouth Theme";
            platforms = pkgs.lib.platforms.linux;
          };
        };

        # Development commands
        apps = {
          # Generate assets into theme directory
          build-assets = {
            type = "app";
            program = toString (pkgs.writeShellScript "build-assets" ''
              # Temporarily set isExporting to true
              sed -i 's/boolean isExporting = false;/boolean isExporting = true;/' serpentine-systems/sketch/sketch.pde
              cd serpentine-systems && ${pkgs.xvfb-run}/bin/xvfb-run -a ${pkgs.processing}/bin/processing-java --sketch="$PWD/sketch" --run
              # Reset isExporting back to false
              sed -i 's/boolean isExporting = true;/boolean isExporting = false;/' sketch/sketch.pde
            '');
          };

          # Preview animation
          preview = {
            type = "app";
            program = toString (pkgs.writeShellScript "preview" ''
              cd serpentine-systems && ${pkgs.processing}/bin/processing-java --sketch="$PWD/sketch" --run
            '');
          };
        };

        # Development shell
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            plymouth
            processing
            xvfb-run
            xorg.xorgserver
          ];

          shellHook = ''
            echo "Plymouth Theme Development Environment"
            echo ""
            echo "Available commands:"
            echo "  nix run .#build-assets  - Generate theme assets"
            echo "  nix run .#preview       - Preview the animation"
            echo ""
          '';
        };
      }
    );
}
