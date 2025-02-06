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

        # Function to build a specific theme's animations
        buildThemeAnimations = themeName:
          pkgs.stdenv.mkDerivation {
            name = "${themeName}-animations";
            src = ./themes + "/${themeName}";

            nativeBuildInputs = with pkgs; [
              processing
              xvfb-run
              xorg.xorgserver
              gnused
            ];

            buildPhase = ''
              # Set isExporting to true for the build
              sed -i 's/boolean isExporting = false;/boolean isExporting = true;/' sketch/sketch.pde
              cd sketch
              xvfb-run -a processing-java --sketch="$PWD" --run
            '';

            installPhase = ''
              mkdir -p $out
              cp ../plymouth/progress-*.png $out/
            '';
          };
      in {
        # Build specific theme animations
        apps.build-serpentine-rings = {
          type = "app";
          program = toString (pkgs.writeShellScript "build-serpentine-rings" ''
            # Temporarily set isExporting to true
            sed -i 's/boolean isExporting = false;/boolean isExporting = true;/' themes/serpentine-rings/sketch/sketch.pde
            cd themes/serpentine-rings && ${pkgs.xvfb-run}/bin/xvfb-run -a ${pkgs.processing}/bin/processing-java --sketch="$PWD/sketch" --run
            # Reset isExporting back to false
            sed -i 's/boolean isExporting = true;/boolean isExporting = false;/' themes/serpentine-rings/sketch/sketch.pde
          '');
        };

        # Run options for previewing animations
        apps.serpentine-rings = {
          type = "app";
          program = toString (pkgs.writeShellScript "run-serpentine-rings" ''
            cd themes/serpentine-rings && ${pkgs.processing}/bin/processing-java --sketch="$PWD/sketch" --run
          '');
        };

        # Individual theme packages
        packages.serpentine-rings = pkgs.stdenv.mkDerivation {
          pname = "plymouth-theme-serpentine-rings";
          version = "0.1.0";

          src = ./themes/serpentine-rings/plymouth;

          # Build the animations first
          animations = buildThemeAnimations "serpentine-rings";

          nativeBuildInputs = [pkgs.gnused];

          installPhase = ''
            runHook preInstall

            # Create theme directory
            mkdir -p $out/share/plymouth/themes/serpentine-rings

            # Copy theme files
            cp -r $src/* $out/share/plymouth/themes/serpentine-rings/

            # Copy generated animations
            cp -r $animations/* $out/share/plymouth/themes/serpentine-rings/

            # Fix paths in plymouth theme files
            find $out/share/plymouth/themes -name "*.plymouth" -type f | while read -r file; do
              sed -i "s@/usr/@$out/@" "$file"
            done

            runHook postInstall
          '';

          meta = {
            description = "Serpentine Rings Plymouth Theme";
            longDescription = ''
              A monochrome Plymouth theme featuring rotating Serpentine Systems text
              with animated rings.
            '';
            platforms = pkgs.lib.platforms.linux;
          };
        };

        # Collection package containing all themes
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "plymouth-theme-serpentine";
          version = "0.1.0";

          src = ./themes;

          nativeBuildInputs = [pkgs.gnused];

          installPhase = ''
            runHook preInstall

            mkdir -p $out/share/plymouth/themes
            cp -r $src/* $out/share/plymouth/themes/

            # Fix paths in plymouth theme files
            find $out/share/plymouth/themes -name "*.plymouth" -type f | while read -r file; do
              sed -i "s@/usr/@$out/@" "$file"
            done

            runHook postInstall
          '';

          meta = {
            description = "Serpentine Systems Plymouth Theme";
            longDescription = ''
              A collection of Plymouth themes for Serpentine Systems featuring
              various animations and styles.
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
            themePackages = [self.packages.${system}.serpentine-rings];
          };

          environment.systemPackages = [self.packages.${system}.serpentine-rings];
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
            echo "Theme can be built with:"
            echo "  nix build .#serpentine-rings"
            echo ""
            echo "Preview animations with:"
            echo "  nix run .#serpentine-rings"
            echo ""
            echo "Build animations with:"
            echo "  nix run .#build-serpentine-rings"
            echo ""
            echo "Install in your NixOS configuration by importing this flake's nixosModules.default"
            echo ""
          '';
        };
      }
    );
}
