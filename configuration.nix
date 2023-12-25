# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "alfa";

  time.timeZone = "Asia/Bangkok";

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
  security.sudo.extraRules = [{
    users = [ "artslob" ];
    commands = [{
      command = "ALL";
      options = [ "NOPASSWD" "SETENV" ];
    }];
  }];

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    htop
    stow
    nixfmt
    pre-commit
    openvpn
    ripgrep
    fd # alternative to find
    bat # cat clone with syntax highlighting
    exa # alternative to ls
    lsd # alternative to ls
    du-dust # disk usage
    procs # info about processes
    broot # combines tree, cd and more
    zoxide # smarter cd command
    difftastic # syntax-aware diff
    delta # syntax-highlighting pager for git
  ];

  programs.ssh.startAgent = true;

  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  programs.bash.shellAliases = {
    p = "pwd";
    g = "git";
  };

  programs.git = {
    enable = true;
    config = {
      core.editor = "vim";
      init.defaultBranch = "main";
      alias = {
        a = "add";
        s = "status";
        c = "commit";
        d = "diff";
        dc = "diff --cached";
        pu = "push";
        ch = "checkout";
        lol = "log --graph --decorate --pretty=oneline --abbrev-commit";
        lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11";

}
