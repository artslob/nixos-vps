{ config, pkgs, ... }:

let
  startScript = pkgs.writeShellScript "mtprotoproxy-start" ''
    SECRET=$(cat ${config.age.secrets.mtprotoproxy-secret.path} | tr -d '[:space:]')
    CONFIG_DIR=/run/mtprotoproxy
    mkdir -p $CONFIG_DIR
    cat > $CONFIG_DIR/config.py <<PYEOF
    PORT = 8443
    USERS = {"tg": "$SECRET"}
    SECURE_ONLY = True
    TLS_DOMAIN = "www.google.com"
    PYEOF
    exec ${pkgs.mtprotoproxy}/bin/mtprotoproxy $CONFIG_DIR/config.py
  '';
in {
  age.secrets.mtprotoproxy-secret = {
    file = ../secrets/mtprotoproxy-secret.age;
    owner = "root";
    group = "root";
    mode = "0400";
  };

  systemd.services.mtprotoproxy = {
    description = "MTProto Proxy for Telegram";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = startScript;
      Restart = "on-failure";
      RestartSec = "5s";
      RuntimeDirectory = "mtprotoproxy";
      DynamicUser = true;
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 8443 ];
}
