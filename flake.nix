{
  description = "VPS NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
    };
  };

  outputs = { self, nixpkgs, flake-utils, agenix }:
    {
      nixosConfigurations.vps = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          {
            nixpkgs.overlays = [
              (final: prev: {
                github-runner = prev.github-runner.overrideAttrs (oldAttrs: {
                  patches = oldAttrs.patches or [ ]
                    ++ [ ./patches/github-runner.patch ];
                });
              })
            ];
          }
          ./configuration
          agenix.nixosModules.default
        ];
      };
    } // flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nixfmt-classic
            nixos-rebuild
            agenix.packages.${system}.default
            wireguard-tools
            qrencode
          ];
          EDITOR = "vim";
        };
      });
}
