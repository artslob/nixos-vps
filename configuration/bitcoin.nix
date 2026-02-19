{ pkgs, ... }: {
  age.secrets."bitcoind-rpcpassword".file = ../secrets/bitcoind-rpcpassword.age;

  services.bitcoind.main = {
    enable = true;
    extraConfig = ''
      prune=10000

      # JSON-RPC for electrs
      server=1
      rpcuser=bitcoinrpc
      rpcpassword=password

      # ZMQ for electrs indexing:
      zmqpubrawblock=tcp://127.0.0.1:28332
      zmqpubrawtx=tcp://127.0.0.1:28333
    '';
  };

  systemd.services.electrs = {
    description = "Electrum server (electrs)";
    wants = [ "bitcoind.service" ];
    after = [ "bitcoind.service" ];
    serviceConfig.Type = "simple";
    serviceConfig.ExecStart = ''
      ${pkgs.electrs}/bin/electrs \
        --db-dir /var/lib/bitcoind-main \
        --daemon-rpc-addr 127.0.0.1:8332
    '';
    wantedBy = [ "multi-user.target" ];
  };

  environment.etc."electrs/config.toml".text = ''auth="bitcoinrpc:password"'';
}
