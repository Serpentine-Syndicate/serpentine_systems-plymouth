{
  pkgs,
  lib,
  config,
  ...
}: let
  toBG = {
    red,
    green,
    blue,
  }:
    "${toString (red / 255.0)}, "
    + "${toString (green / 255.0)}, "
    + "${toString (blue / 255.0)}";
  cfg = config;
  serpentine-boot = pkgs.callPackage ./default.nix {
    theme = cfg.serpentine-boot.theme;
    bgColor = toBG cfg.serpentine-boot.bgColor;
  };
in {
  options.serpentine-boot.enable = lib.mkEnableOption "serpentine-boot";
  options.serpentine-boot.bgColor.red = lib.mkOption {
    type = lib.types.ints.between 0 255;
    default = 255;
  };
  options.serpentine-boot.bgColor.green = lib.mkOption {
    type = lib.types.ints.between 0 255;
    default = 255;
  };
  options.serpentine-boot.bgColor.blue = lib.mkOption {
    type = lib.types.ints.between 0 255;
    default = 255;
  };
  options.serpentine-boot.theme = lib.mkOption {
    type = lib.types.enum ["load_unload" "evil-nixos" "serpentinesystems"];
    default = "load_unload";
  };
  options.serpentine-boot.duration = lib.mkOption {
    type = lib.types.float;
    default = 0.0;
  };
  config.boot.plymouth = lib.mkIf cfg.serpentine-boot.enable {
    enable = true;
    themePackages = [serpentine-boot];
    theme = cfg.serpentine-boot.theme;
  };
  config.systemd.services.plymouth-quit = lib.mkIf (cfg.serpentine-boot.enable && cfg.serpentine-boot.duration > 0.0) {
    preStart = "${pkgs.coreutils}/bin/sleep ${toString config.serpentine-boot.duration}";
  };
}
