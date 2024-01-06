# VPS NixOS config

## Installation from VNC

Before following steps from [official manual](https://nixos.org/manual/nixos/stable/#sec-installation-manual)
you need to setup installation environment as root:

```bash
ifconfig <interface name> <server ip address> netmask <netmask>
route add default gw <gateway IP> <interface name>

# should work now
ping 1.1

# setting dns
echo "nameserver 8.8.4.4" > /etc/resolv.conf
```

To get interface name run `ip a`.

To allow ssh connection to installation image from local computer (without
using VNC):

```bash
mkdir ~/.ssh
curl -L https://github.com/artslob.keys > ~/.ssh/authorized_keys
```

Connect with ssh and do Legacy Boot (MBR) installation by [manual](https://nixos.org/manual/nixos/stable/#sec-installation-manual):
```
parted /dev/sda -- mklabel msdos
parted /dev/sda -- mkpart primary 1MB -5GB
parted /dev/sda -- set 1 boot on
parted /dev/sda -- mkpart primary linux-swap -5GB 100%

mkfs.ext4 -L nixos /dev/sda1
mkswap -L swap /dev/sda2

mount /dev/disk/by-label/nixos /mnt
swapon /dev/sda2

nixos-generate-config --root /mnt
vim /mnt/etc/nixos/configuration.nix
```

To get download link for config [click here](https://github.com/artslob/nixos-vps/raw/installation-steps/configuration.nix).

```
curl -L '<link>' > /mnt/etc/nixos/configuration.nix
nixos-install
```

// TODO note about uploading ssh keys to `/root/.ssh`

If you already made partitions and want just to reinstall OS:

```bash
mount /dev/disk/by-label/nixos /mnt
swapon /dev/vda2
```

## Installation

When you loaded to installed OS you need to download this project
and make symbolic link to it from `/etc/nixos`:

```bash
git clone https://github.com/artslob/nixos-vps.git
cp /etc/nixos/hardware-configuration.nix nixos-vps
rm -rf /etc/nixos
ln -s "$(pwd)/nixos-vps" /etc/nixos
```

## VPS naming

For pets: international radiotelephony
[spelling alphabet](https://namingschemes.com/Phonetic_Alphabet).  
For cattle: currently not used.
