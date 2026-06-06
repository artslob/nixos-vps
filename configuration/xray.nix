{ config, pkgs, ... }:

let
  xrayConfigBase = pkgs.writeText "xray-config-base.json" (
    builtins.toJSON {
      log = {
        loglevel = "warning";
      };
      inbounds = [
        {
          listen = "0.0.0.0";
          port = 443;
          protocol = "vless";
          settings = {
            clients = [
              {
                id = "PLACEHOLDER_UUID";
                flow = "";
              }
            ];
            decryption = "none";
          };
          streamSettings = {
            network = "xhttp";
            security = "reality";
            realitySettings = {
              show = false;
              dest = "127.0.0.1:8444";
              xver = 0;
              serverNames = [
                "www.artslob.me"
                "artslob.me"
              ];
              privateKey = "PLACEHOLDER_KEY";
              shortIds = [ "PLACEHOLDER_SID" ];
            };
            xhttpSettings = { };
          };
        }
      ];
      outbounds = [ { protocol = "freedom"; } ];
    }
  );

  startScript = pkgs.writeShellScript "xray-start" ''
    set -euo pipefail

    UUID=$(cat ${config.age.secrets.xray-uuid.path} | tr -d '[:space:]')
    PRIVATE_KEY=$(cat ${config.age.secrets.xray-reality-private-key.path} | tr -d '[:space:]')
    SHORT_ID=$(cat ${config.age.secrets.xray-short-id.path} | tr -d '[:space:]')

    ${pkgs.jq}/bin/jq \
      --arg uuid "$UUID" \
      --arg pk "$PRIVATE_KEY" \
      --arg sid "$SHORT_ID" \
      '
        .inbounds[0].settings.clients[0].id = $uuid |
        .inbounds[0].streamSettings.realitySettings.privateKey = $pk |
        .inbounds[0].streamSettings.realitySettings.shortIds = [$sid]
      ' ${xrayConfigBase} > /run/xray/config.json

    exec ${pkgs.xray}/bin/xray run -config /run/xray/config.json
  '';
in
{
  age.secrets.xray-uuid = {
    file = ../secrets/xray-uuid.age;
    owner = "xray";
    group = "xray";
    mode = "0400";
  };

  age.secrets.xray-reality-private-key = {
    file = ../secrets/xray-reality-private-key.age;
    owner = "xray";
    group = "xray";
    mode = "0400";
  };

  age.secrets.xray-short-id = {
    file = ../secrets/xray-short-id.age;
    owner = "xray";
    group = "xray";
    mode = "0400";
  };

  users.users.xray = {
    isSystemUser = true;
    group = "xray";
  };
  users.groups.xray = { };

  systemd.services.xray = {
    description = "Xray VLESS+XHTTP+Reality Proxy";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = startScript;
      User = "xray";
      Group = "xray";
      Restart = "on-failure";
      RestartSec = "5s";
      RuntimeDirectory = "xray";
      RuntimeDirectoryMode = "0700";
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
    };
  };
}
