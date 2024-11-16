# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "alfa";

  time.timeZone = "Asia/Bangkok";

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "artslob" ];
  };

  users.users.artslob = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    # nix-shell -p mkpasswd --run 'mkpasswd -m sha-512'
    initialHashedPassword =
      "$6$pMUxmD1xGTuyNGy2$4M2s8wWzN4xuRA/vdJ3pToP.Fh5WLr9ldMKT3wOM.LX3kOpi9UrzjzvNZWbb4rq03zJ3V9Yc2m71tWWKjvPuU0";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFI44vpL8QXr0L4jeuq3gXD8y+/fLumPvKVAjIyNcr+"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDGu+Aro+2eufX4/TsFavrtOuS+NUqXKAFa0GhQK+uaGS0h3fQhy+t2P8iLerWpORuGUfmrGHR8eHiug6rzRQTQWWaMWrJW+8pydxtNqoBmOxs85KRbuLUZZyUb5hJG/tkFTJUHVADMQ4CI7vuu+ofdkQlhhtaRwqyTLP3HSEz782H46AYsgH4j10hpCtY86bdnCL18y+FdSy2rp7lbrNyHYT/ezwkf0hhzXhCydfaxOdMP5xr+4hXblPkexXjX5iWmeSaBhnlsdMt6qd3yP3JVde92LCyAf5TZNWhRbFZx48UfBMvOh+ADTDS6iv764svFSw5Cp6TcJzM3eobJuTnAC3aSXZnotomTud5c+BKAzFdbCbAm6b/pZ/x5tycWJSXz3M82c3FZZ5Tm5hT9zeYbxyvHdhrCEBVwN5WkdI3DJaIOJ4yZZMVM9nYoCnwA4HBI4D19A/w1F7tgPAeFM97RMKwaxzBZsV0H9H3f0czx6FsqSq/2wJDQLhX+DtaEZhOQzR3b6gOgN4XUlkvuACVMFtMtfIhQY00lCyWL3yuiMoHiuoE2vidb1b2lW+cAjgRV31NO4x7m2lV2fPTae/zmlk/Z4faKNb4CUOUwUUBVhJiYt1oeWxDQhXtEjZ5+plkAoMvPXE5jQ2mLzkc8qYHoqqqtIj4uG5r+J0gCgkesXQ== artslob@yandex.ru"
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
    nixfmt-classic
    pre-commit
    openvpn
    ripgrep
    fd # alternative to find
    bat # cat clone with syntax highlighting
    eza # alternative to ls
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
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      ClientAliveInterval = 60;
      ClientAliveCountMax = 30;
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts."www.artslob.me" = {
      forceSSL = true;
      enableACME = true;
      default = true;
      serverAliases = [ "artslob.me" "artslob.ru" "www.artslob.ru" ];
      root = "/etc/artslob.me/www-fallout";
    };
    virtualHosts."subd-rk-1.artslob.me" = {
      forceSSL = true;
      enableACME = true;
      serverAliases = [ "subd-rk-1.artslob.ru" ];
      root = "/etc/subd_rk/rk1";
      locations."/" = { extraConfig = "autoindex on;"; };
    };
    virtualHosts."subd-rk-2.artslob.me" = {
      forceSSL = true;
      enableACME = true;
      serverAliases = [ "subd-rk-2.artslob.ru" ];
      root = "/etc/subd_rk/rk2";
      locations."/" = { extraConfig = "autoindex on;"; };
    };
    virtualHosts."share.artslob.me" = {
      forceSSL = true;
      enableACME = true;
      serverAliases = [ "share.artslob.ru" ];
      root = "/etc/artslob.me/share";
      locations."/" = { extraConfig = "autoindex on;"; };
    };
  };

  environment.etc."artslob.me".source = builtins.fetchGit {
    url = "https://github.com/artslob/artslob.ru";
    rev = "a2abeb1ab978845a5b314a949bc252aab41b58f1";
  };

  environment.etc."subd_rk".source = builtins.fetchGit {
    url = "https://github.com/artslob/SUBD_RK";
    rev = "ab116e7df29d9d77c044fe77ec099c822102453f";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "artyomslob@gmail.com";
    # TODO remove
    # defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory";
    certs."www.artslob.me" = {
      webroot = "/var/lib/acme/acme-challenge";
      email = "artyomslob@gmail.com";
      # Ensure that the web server you use can read the generated certs
      # Take a look at the group option for the web server you choose.
      group = "nginx";
      # Since we have a wildcard vhost to handle port 80,
      # we can generate certs for anything!
      # Just make sure your DNS resolves them.
      extraDomainNames = [ "subd-rk-1.artslob.me" "subd-rk-2.artslob.me" ];
    };
  };

  # /var/lib/acme/.challenges must be writable by the ACME user
  # and readable by the Nginx user. The easiest way to achieve
  # this is to add the Nginx user to the ACME group.
  users.users.nginx.extraGroups = [ "acme" ];

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

  services.github-runners = {
    test-github-runner = {
      enable = true;
      name = "test-github-runner";
      tokenFile = config.age.secrets."test-github-runner-token".path;
      url = "https://github.com/artslob/test-github-runner";
    };
  };

  age.secrets.secret1.file = ./secrets/secret1.age;
  age.secrets."test-github-runner-token".file =
    ./secrets/test-github-runner-token.age;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11";

}
