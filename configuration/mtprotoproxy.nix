{ config, pkgs, ... }:

let
  secretPath = config.age.secrets.mtprotoproxy-secret.path;

  startScript = pkgs.writeShellScript "mtprotoproxy-start" ''
    SECRET=$(cat ${secretPath} | tr -d '[:space:]')
    CONFIG_DIR=/run/mtprotoproxy
    mkdir -p $CONFIG_DIR
    cat > $CONFIG_DIR/config.py <<PYEOF
    PORT = 8443
    USERS = {"tg": "$SECRET"}
    MODES = {
        "classic": False,
        "secure": True,
        "tls": True
    }
    TLS_DOMAIN = "pages.cloudflare.com"
    PYEOF
    exec ${pkgs.mtprotoproxy}/bin/mtprotoproxy $CONFIG_DIR/config.py
  '';
in
{
  users.users.mtprotoproxy = {
    isSystemUser = true;
    group = "mtprotoproxy";
  };
  users.groups.mtprotoproxy = { };

  age.secrets.mtprotoproxy-secret = {
    file = ../secrets/mtprotoproxy-secret.age;
    owner = "mtprotoproxy";
    group = "mtprotoproxy";
    mode = "0400";
  };

  systemd.services.mtprotoproxy = {
    description = "MTProto Proxy for Telegram";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = startScript;
      User = "mtprotoproxy";
      Group = "mtprotoproxy";
      Restart = "on-failure";
      RestartSec = "5s";
      RuntimeDirectory = "mtprotoproxy";
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 8443 ];
}
