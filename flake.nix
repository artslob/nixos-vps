{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.vps = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          nixpkgs.overlays = [
            (final: prev: {
              github-runner = prev.github-runner.overrideAttrs (oldAttrs: {
                patches = oldAttrs.patches or [ ] ++ [ ./github-runner.patch ];
              });
            })
          ];
        }
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect
        ./configuration.nix
        inputs.agenix.nixosModules.default
      ];
    };
  };
}
