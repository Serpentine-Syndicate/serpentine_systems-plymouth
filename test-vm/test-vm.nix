# Edit configuration.nix to add VM support
{
  config,
  pkgs,
  ...
}: {
  # Enable VM support
  virtualisation = {
    memorySize = 4096; # 4GB RAM
    cores = 4; # 4 CPU cores
    graphics = true; # Enable graphical output for Plymouth
  };

  # Add a delay service to keep Plymouth visible
  systemd.services.delay = {
    description = "Add delay to see Plymouth";
    script = "sleep 10";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  boot = {
    plymouth = {
      enable = true;
      theme = "rings";
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
          selected_themes = ["rings"];
        })
      ];
    };

    # Enable "Silent Boot" as recommended in the wiki
    consoleLogLevel = 0;
    initrd = {
      verbose = false;
      systemd.enable = true;
      kernelModules = ["virtio_gpu" "virtio_pci"];
      availableKernelModules = ["virtio_gpu" "virtio_pci" "virtio_blk" "virtio_scsi" "virtio_net"];
    };

    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "plymouth.enable=1"
    ];

    loader.timeout = 0;
  };

  # Basic system configuration
  system.stateVersion = "23.11";
}
