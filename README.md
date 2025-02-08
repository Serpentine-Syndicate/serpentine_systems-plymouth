# Serpentine Systems Plymouth Theme

A sleek Plymouth boot animation theme for NixOS, featuring the Serpentine Systems logo.

**Warning: Using this repo for some reason bloats the `initrd` quite a bit (up to 50 MB). Use it with [boot.loader.systemd-boot.configurationLimit](https://search.nixos.org/options?channel=23.05&show=boot.loader.systemd-boot.configurationLimit&from=0&size=50&sort=relevance&type=packages&query=systemd-boot) or a `/boot` of at least a gigabyte.
On EFI Systems it's also possible to keep the initrd on the main partition when switching to Grub. Checkout the [nixos wiki](https://wiki.nixos.org/wiki/Bootloader#Keeping_kernels/initrd_on_the_main_partition).**

## Preview

![Serpentine Systems Boot Animation](./serpentine-preview.gif)

## Installation

This theme is available as a Nix flake. Add it to your `flake.nix`:

```nix
{
  inputs.serpentine-boot.url = "github:00x29a/serpentine_systems-plymouth";
  
  outputs = { self, nixpkgs, serpentine-boot }: {
    nixosConfigurations."<hostname>" = nixpkgs.lib.nixosSystem {
      modules = [ 
        serpentine-boot.nixosModules.default 
        ./configuration.nix 
      ];
      system = "x86_64-linux";
    };
  };
}
```

## Configuration

Enable the theme in your NixOS configuration:

```nix
{
  serpentine-boot = {
    enable = true;
    
    # Optional: Customize background color (RGB values 0-255)
    # Default is black (0,0,0)
    # bgColor = {
    #   red = 128;    # 0-255
    #   green = 0;    # 0-255
    #   blue = 128;   # 0-255
    # };
    
    # Optional: Set minimum display duration (in seconds)
    # duration = 3.0;
  };
}
```

## Background Color Examples

You can customize the background color using RGB values (0-255):
- Black (default): `{red = 0; green = 0; blue = 0;}`
- White: `{red = 255; green = 255; blue = 255;}`
- Purple: `{red = 128; green = 0; blue = 128;}`
- Dark Blue: `{red = 0; green = 0; blue = 77;}`

## Development

The theme uses Plymouth's script system for animations. The main components are:
- `serpentinesystems.plymouth`: Theme configuration
- `serpentinesystems.script`: Animation script
- PNG frames for the animation sequence
