{ config, lib, pkgs, ... }: {
  networking.nat.enable = true;
  networking.nat.externalInterface = "ens18";
  networking.nat.internalInterfaces = [ "wg0" ];
  networking.nat.enableIPv6 = true;
  networking.firewall = { allowedUDPPorts = [ 51820 ]; };
  networking.enableIPv6 = true;
  boot.kernel.sysctl = { "net.ipv6.conf.all.forwarding" = "1"; };

  age.secrets."wireguard-private-key".file =
    ./secrets/wireguard-private-key.age;

  networking.wireguard.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP address and subnet of the server's end of the tunnel interface.
      ips = [ "10.100.0.1/24" "fd42:42:42::1/64" ];

      # The port that WireGuard listens to. Must be accessible by the client.
      listenPort = 51820;

      # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
      # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o ens18 -j MASQUERADE
        ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -s fd42:42:42::/64 ! -d fd42:42:42::/64 -j MASQUERADE
      '';

      # This undoes the above command
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o ens18 -j MASQUERADE
        ${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING -s fd42:42:42::/64 ! -d fd42:42:42::/64 -j MASQUERADE
      '';

      # Path to the private key file.
      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      # Public key is "dxEQSmJWCwdfgClqdlJqU67/VygySWjF/aL38twE6BE="
      privateKeyFile = config.age.secrets."wireguard-private-key".path;

      peers = [
        # List of allowed peers.
        { # Feel free to give a meaning full name
          # Public key of the peer (not a file path).
          publicKey = "2wrhPpl3w6BM06BzNQRkgGMmIOwGaEFLMImGZY9iYS8=";
          # List of IPs assigned to this peer within the tunnel subnet. Used to configure routing.
          allowedIPs = [ "10.100.0.2/32" "fd42:42:42::2/128" ];
        }
      ];
    };
  };
}
