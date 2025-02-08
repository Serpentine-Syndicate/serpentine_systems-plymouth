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
          version = "0.2.0";

          src = ./serpentinesystems;

          # nativeBuildInputs = with pkgs; [
          #   gnused
          #   plymouth
          # ];

          dontBuild = true;

          installPhase = ''
            runHook preInstall

            # Create theme directory
            mkdir -p $out/share/plymouth/themes/serpentinesystems

            # Copy theme files
            cp -r * $out/share/plymouth/themes/serpentinesystems/

            # Fix paths in plymouth theme files
            substituteInPlace $out/share/plymouth/themes/serpentinesystems/serpentinesystems.plymouth \
              --replace-fail "/usr/" "$out/"

            # Ensure correct permissions
            chmod -R 755 $out/share/plymouth/themes/serpentinesystems

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
              sed -i 's/boolean isExporting = false;/boolean isExporting = true;/' serpentinesystems/sketch/sketch.pde
              cd serpentinesystems && ${pkgs.xvfb-run}/bin/xvfb-run -a ${pkgs.processing}/bin/processing-java --sketch="$PWD/sketch" --run
              # Reset isExporting back to false
              sed -i 's/boolean isExporting = true;/boolean isExporting = false;/' sketch/sketch.pde
            '');
          };

          # Preview animation
          preview = {
            type = "app";
            program = toString (pkgs.writeShellScript "preview" ''
              cd serpentinesystems && ${pkgs.processing}/bin/processing-java --sketch="$PWD/sketch" --run
            '');
          };
        };

        # Development shell
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
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
