# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda";
  virtualisation.hypervGuest.enable = false;

  networking.hostName = "bravo";
  networking.interfaces.ens3.ipv4.addresses = [{
    address = "176.124.219.171";
    prefixLength = 24;
  }];
  networking.defaultGateway = "176.124.219.1";
  networking.nameservers = [ "8.8.8.8" "8.8.4.4" ];

  time.timeZone = "Europe/Moscow";

  users.users.artslob = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    # nix-shell -p mkpasswd --run 'mkpasswd -m sha-512'
    initialHashedPassword =
      "$6$pMUxmD1xGTuyNGy2$4M2s8wWzN4xuRA/vdJ3pToP.Fh5WLr9ldMKT3wOM.LX3kOpi9UrzjzvNZWbb4rq03zJ3V9Yc2m71tWWKjvPuU0";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFI44vpL8QXr0L4jeuq3gXD8y+/fLumPvKVAjIyNcr+"
    ];
  };
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFI44vpL8QXr0L4jeuq3gXD8y+/fLumPvKVAjIyNcr+"
  ];

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    htop
    stow
    nixfmt
    pre-commit
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05";

}

