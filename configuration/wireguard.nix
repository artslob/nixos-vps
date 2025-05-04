{ config, lib, pkgs, ... }: {
  networking.nat = {
    enable = true;
    externalInterface = "ens18";
    internalInterfaces = [ "wg0" ];
    enableIPv6 = true;
  };
  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 51820 ];
  };
  networking.enableIPv6 = true;
  boot.kernel.sysctl = {
    "net.ipv6.conf.all.forwarding" = "1";
    "net.ipv6.conf.default.forwarding" = "1";
  };
  services.dnsmasq = {
    enable = true;
    settings.interface = "wg0";
  };

  age.secrets."wireguard-private-key".file =
    ../secrets/wireguard-private-key.age;

  # "wg0" is the network interface name. You can name the interface arbitrarily.
  networking.wg-quick.interfaces.wg0 = {
    # Determines the IP address and subnet of the server's end of the tunnel interface.
    address = [ "10.0.0.1/24" "fdc9:281f:04d7:9ee9::1/64" ];

    # The port that WireGuard listens to. Must be accessible by the client.
    listenPort = 51820;

    # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
    # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
    postUp = ''
      ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.0.0.1/24 -o ens18 -j MASQUERADE
      ${pkgs.iptables}/bin/ip6tables -A FORWARD -i wg0 -j ACCEPT
      ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -s fdc9:281f:04d7:9ee9::1/64 -o ens18 -j MASQUERADE
    '';

    # This undoes the above command
    preDown = ''
      ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.0.0.1/24 -o ens18 -j MASQUERADE
      ${pkgs.iptables}/bin/ip6tables -D FORWARD -i wg0 -j ACCEPT
      ${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING -s fdc9:281f:04d7:9ee9::1/64 -o ens18 -j MASQUERADE
    '';

    # Public key is "badrGTyvIsmQUK1k2rjSUxfInUdJXjWzsq0qm86Df3E="
    privateKeyFile = config.age.secrets."wireguard-private-key".path;

    peers = [{
      publicKey = "xPcwiKuWVZvG/Q+1fMoHarC+SXUnmpAgxrC6OOHx9As=";
      # List of IPs assigned to this peer within the tunnel subnet. Used to configure routing.
      allowedIPs = [ "10.0.0.2/32" "fdc9:281f:04d7:9ee9::2/128" ];
    }];
  };
}
