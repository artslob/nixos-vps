{ pkgs ? import (fetchTarball
  "https://github.com/NixOS/nixpkgs/archive/refs/tags/24.05.tar.gz") { }
, agenix ?
  (builtins.fetchTarball "https://github.com/ryantm/agenix/archive/main.tar.gz")
}:

pkgs.mkShell {
  buildInputs = with pkgs; [
    nixos-rebuild
    (pkgs.callPackage "${agenix}/pkgs/agenix.nix" { })
  ];

  nativeBuildInputs = with pkgs; [ pkg-config ];

  EDITOR = "vim";
}
