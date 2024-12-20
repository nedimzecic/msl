# macOS Subsystem for Linux

A small WSL2-like tool for running lightweight linux virtual machines on macOS. Code is based on Apple's Virtualization framework examples. This is pure terminal application therefore ISO installer has to support serial console output.

```
msl --help

USAGE: msl <subcommand>

OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  install
  list
  start

  See 'msl help <subcommand>' for detailed help.
```

### Install subcommand
```
msl install --help

USAGE: msl install --name <name> [--cpu <cpu>] [--ram <ram>] [--disk <disk>] [--mac <mac>] [--nvme] --iso <iso>

OPTIONS:
  --name <name>           Virtual machine name
  --cpu <cpu>             Number of CPUs VM will use (default: 2)
  --ram <ram>             RAM size in MB (default: 512)
  --disk <disk>           Disk size in GB (default: 16)
  --mac <mac>             Network device MAC address
  --nvme <nvme>           Create storage as NVME storage device
  --iso <iso>             Path to ISO image
  -h, --help              Show help information.
```

### Start subcommand
```
msl start --help

USAGE: msl start --name <name> [--cpu <cpu>] [--ram <ram>] [--mac <mac>] [--nvme]

OPTIONS:
  --name <name>           Virtual machine name
  --cpu <cpu>             Number of CPUs VM will use (default: 2)
  --ram <ram>             RAM size in MB (default: 512)
  --mac <mac>             Network device MAC address
  --nvme <nvme>           Create storage as NVME storage device
  -h, --help              Show help information.
```

### Install example
```
msl install --name ubuntu-2404 --cpu 2 --ram 2048 --disk 64 --iso ~/Downloads/ubuntu-24.04.1-live-server-arm64.iso

```

### Start example
```
msl start --name ubuntu-2404 --cpu 2 --ram 2048 --mac d6:94:96:e2:bd:aa

```

### List example
```
msl list

alpine
debian-11
debian-12
ubuntu-2204
ubuntu-2404
```

### DHCP server reservation
Modify /var/db/dhcpd_leases file, then start VM with custom MAC address.
```
{
  name=ubuntu
  ip_address=192.168.64.254
  hw_address=1,a8:e1:be:a5:4d:6f
  identifier=1,a8:e1:be:a5:4d:6f
  lease=0x66c43d2f
}
```

### Resizing rootfs image
```sh
brew install qemu
```
```sh
qemu-img resize rootfs.img 128G
```
