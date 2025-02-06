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

        apps.build-serpentine-static = {
          type = "app";
          program = toString (pkgs.writeShellScript "build-serpentine-static" ''
            # Temporarily set isExporting to true
            sed -i 's/boolean isExporting = false;/boolean isExporting = true;/' themes/serpentine-static/sketch/sketch.pde
            cd themes/serpentine-static && ${pkgs.xvfb-run}/bin/xvfb-run -a ${pkgs.processing}/bin/processing-java --sketch="$PWD/sketch" --run
            # Reset isExporting back to false
            sed -i 's/boolean isExporting = true;/boolean isExporting = false;/' themes/serpentine-static/sketch/sketch.pde
          '');
        };

        # Run options for previewing animations
        apps.serpentine-rings = {
          type = "app";
          program = toString (pkgs.writeShellScript "run-serpentine-rings" ''
            cd themes/serpentine-rings && ${pkgs.processing}/bin/processing-java --sketch="$PWD/sketch" --run
          '');
        };

        apps.serpentine-static = {
          type = "app";
          program = toString (pkgs.writeShellScript "run-serpentine-static" ''
            cd themes/serpentine-static && ${pkgs.processing}/bin/processing-java --sketch="$PWD/sketch" --run
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

        packages.serpentine-static = pkgs.stdenv.mkDerivation {
          pname = "plymouth-theme-serpentine-static";
          version = "0.1.0";

          src = ./themes/serpentine-static/plymouth;

          # Build the animations first
          animations = buildThemeAnimations "serpentine-static";

          nativeBuildInputs = [pkgs.gnused];

          installPhase = ''
            runHook preInstall

            # Create theme directory
            mkdir -p $out/share/plymouth/themes/serpentine-static

            # Copy theme files
            cp -r $src/* $out/share/plymouth/themes/serpentine-static/

            # Copy generated animations
            cp -r $animations/* $out/share/plymouth/themes/serpentine-static/

            # Fix paths in plymouth theme files - modified to handle paths correctly
            find $out/share/plymouth/themes -name "*.plymouth" -type f | while read -r file; do
              # First, fix the /usr/ paths
              sed -i "s@/usr/@$out/@" "$file"
              # Then fix any double themes/themes paths
              sed -i "s@themes/themes/@themes/@g" "$file"
            done

            runHook postInstall
          '';

          meta = {
            description = "Serpentine Static Plymouth Theme";
            longDescription = ''
              A monochrome Plymouth theme featuring rotating Serpentine Systems text
              with an organic static effect in the center.
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
          options.boot.plymouth.serpentineTheme = lib.mkOption {
            type = lib.types.enum ["rings" "static"];
            default = "rings";
            description = "Which Serpentine Systems theme to use (rings or static)";
          };

          config = {
            boot.plymouth = {
              enable = true;
              theme =
                if config.boot.plymouth.serpentineTheme == "rings"
                then "serpentine-rings"
                else "serpentine-static";
              themePackages = [
                self.packages.${system}.serpentine-rings
                self.packages.${system}.serpentine-static
              ];
            };

            environment.systemPackages = [
              self.packages.${system}.serpentine-rings
              self.packages.${system}.serpentine-static
            ];
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
            echo "Themes can be built with:"
            echo "  nix build .#serpentine-rings"
            echo "  nix build .#serpentine-static"
            echo ""
            echo "Preview animations with:"
            echo "  nix run .#serpentine-rings"
            echo "  nix run .#serpentine-static"
            echo ""
            echo "Build animations with:"
            echo "  nix run .#build-serpentine-rings"
            echo "  nix run .#build-serpentine-static"
            echo ""
            echo "Install in your NixOS configuration by importing this flake's nixosModules.default"
            echo "and setting boot.plymouth.serpentineTheme to either 'rings' or 'static'"
            echo ""
          '';
        };
      }
    );
}
