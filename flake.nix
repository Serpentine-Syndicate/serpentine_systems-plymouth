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

            # Ensure proper permissions
            chmod 644 $out/share/plymouth/themes/serpentine/*
          '';
        };

        # NixOS module for easy integration in VMs or real systems
        nixosModules.default = {
          config,
          lib,
          pkgs,
          ...
        }: {
          boot.plymouth = {
            enable = true;
            theme = "serpentine";
          };

          environment.systemPackages = [self.packages.${system}.default];
        };

        packages.test-vm =
          (nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              self.nixosModules.${system}.default
              ({pkgs, ...}: {
                system.stateVersion = "23.11";

                # Basic VM settings
                virtualisation = {
                  cores = 2;
                  memorySize = 2048;
                  graphics = true;
                  resolution = {
                    x = 1024;
                    y = 768;
                  }; # Set custom resolution
                  qemu = {
                    options = [
                      "-vga virtio" # Better graphics performance
                      "-display gtk,grab-on-hover=on" # Better mouse handling
                    ];
                  };
                };

                # Fast boot for quick testing
                boot.loader.timeout = 0;
                boot.kernelParams = ["plymouth.enable=1" "quiet" "splash"];

                # Basic user setup
                users.users.tester = {
                  isNormalUser = true;
                  extraGroups = ["wheel"];
                  initialPassword = "test";
                };
              })
            ];
          })
          .config
          .system
          .build
          .vm;

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            plymouth
            imagemagick # For image processing
            gimp # For creating/editing theme assets
            qemu # For running the VM
            spice-gtk # For better VM display
          ];

          shellHook = ''
            echo "Plymouth Theme Development Environment"
            echo ""
            echo "To test in VM:"
            echo "  nix build .#test-vm"
            echo "  ./result/bin/run-*"
            echo ""
            echo "VM Controls:"
            echo "  Ctrl+Alt+G - Release mouse grab"
            echo "  Ctrl+Alt+F - Toggle fullscreen"
            echo "  Ctrl+Alt+Q - Quit VM"
            echo ""
            echo "The theme will be pre-installed in the VM."
            echo "Username: tester"
            echo "Password: test"
            echo ""
          '';
        };
      }
    );
}
