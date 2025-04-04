{
  pkgs ? import <nixpkgs> {},
  theme ? "load_unload",
  # TODO: Should be a list when more themes come
  bgColor ? "0, 0, 0",
  # rgb value between 0-1. TODO: Write hex to plymouth magic
}:
pkgs.stdenv.mkDerivation {
  pname = "serpentine-boot";
  version = "0.2.0";

  src = ./src;

  buildInputs = [
    pkgs.git
  ];

  unpackPhase = ''
  '';

  buildPhase = ''
    # Create theme
    cp template.plymouth "${theme}/${theme}.plymouth"
    sed -i 's/THEME/${theme}/g' "${theme}/${theme}.plymouth"
    sed -i 's/generic/${theme}/g' "${theme}/${theme}.plymouth"
    # Set the Background Color
    sed -i 's/\(Window\.SetBackground[^ ]*\).*/\1 (${bgColor});/' ${theme}/${theme}.script
  '';

  installPhase = ''
    # Copy files
    install -m 755 -vDt "$out/share/plymouth/themes/${theme}" "${theme}/${theme}."{plymouth,script}
    install -m 644 -vDt "$out/share/plymouth/themes/${theme}" "${theme}/"*png
    # Fix path
    sed -i "s@\/usr\/@$out\/@" "$out/share/plymouth/themes/${theme}/${theme}.plymouth"
  '';
}
