let
  pkgs_url = "https://github.com/NixOS/nixpkgs/archive/refs/tags/24.05.tar.gz";
  agenix_url =
    "https://github.com/ryantm/agenix/archive/f6291c5935fdc4e0bef208cfc0dcab7e3f7a1c41.tar.gz";
in { pkgs ? import (fetchTarball {
  url = pkgs_url;
  sha256 = "1lr1h35prqkd1mkmzriwlpvxcb34kmhc9dnr48gkm8hh089hifmx";
}) { }, agenix ? (fetchTarball {
  url = agenix_url;
  sha256 = "1x8nd8hvsq6mvzig122vprwigsr3z2skanig65haqswn7z7amsvg";
}) }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    nixfmt-classic
    nixos-rebuild
    (pkgs.callPackage "${agenix}/pkgs/agenix.nix" { })
  ];

  nativeBuildInputs = with pkgs; [ pkg-config ];

  EDITOR = "vim";
}
