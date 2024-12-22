# macOS Subsystem for Linux

A small WSL2-like tool for running lightweight linux virtual machines on macOS. Code is based on Apple's Virtualization framework examples. Virtual machine bundles are stored in ~/.msl directory. This tool was intended to be pure terminal however some installers do not support serial console thus --graphics flag was added which will virtualize graphics device.
```
msl --help

USAGE: msl --name <name> [--cpu <cpu>] [--ram <ram>] [--disk <disk>] [--nvme] [--mac <mac>] [--graphics] [--iso <iso>]

OPTIONS:
  --name <name>           Virtual machine name
  --cpu <cpu>             Number of CPUs VM will use (default: 2)
  --ram <ram>             RAM size in MB (default: 512)
  --disk <disk>           Disk size in GB (default: 16)
  --nvme                  Create storage as NVME storage device
  --mac <mac>             Network device MAC address
  --graphics              Create virtio graphics device
  --iso <iso>             Path to ISO image
  -h, --help              Show help information.
```

### Ubuntu example
Ubuntu's installer will autodetect hvc0 serial console therefore process is straightforward. In this example we will virtualize rootfs image as NVME block device with size of 64 GB. Download ubuntu-24.04.1-live-server-arm64.iso and boot:
```
msl --name noble --cpu 2 --ram 2048 --disk 64 --nvme --mac 96:eb:d3:f9:24:ad --iso ~/Downloads/ubuntu-24.04.1-live-server-arm64.iso
```
After install you can use vm with:
```
msl --name noble --cpu 2 --ram 2048 --nvme --mac 96:eb:d3:f9:24:ad; reset
```

### Alpine example
Alpine will not detect hvc0 so we will do initial boot with graphics device (--graphics flag). We will use virtual aarch64 type of iso:
```
msl --name alpine --cpu 2 --ram 512 --disk 16 --mac e6:7b:15:04:77:05 --graphics --iso ~/Downloads/alpine-virt-3.21.0-aarch64.iso
```
After doing installation with setup-alpine helper we need to adjust system to use serial console. We will change GRUB_CMDLINE_LINUX_DEFAULT line in /etc/default/grub by appending console=hvc0:
```
GRUB_CMDLINE_LINUX_DEFAULT="modules=sd-mod,usb-storage,ext4,nvme rootfstype=ext4 console=hvc0"
```
Next add following line to /etc/inittab:
```
hvc0::respawn:/sbin/getty -L 115200 hvc0 vt100
```
After doing update-grub we can boot vm without graphics and input devices.
```
msl --name alpine --cpu 2 --ram 512 --mac e6:7b:15:04:77:05; reset
```

### Debian example
Debian will also not detect hvc0 so we start installer with graphics:
```
msl --name bookworm --cpu 2 --ram 1024 --disk 32 --nvme --mac 12:9c:e5:86:26:6c --graphics --iso ~/Downloads/debian-12.8.0-arm64-netinst.iso
```
After install we need to modify /etc/default/grub:
```
GRUB_CMDLINE_LINUX="console=tty0 console=hvc0"
```
We also need to enable virtio_console driver inside initrd, as it's not enabled by default. This is done by adding following line to /etc/initramfs-tools/modules:
```
virtio_console
```
After doing update-grub and update-initramfs -u we can boot vm without graphics and input devices.
```
msl --name bookworm --cpu 2 --ram 1024 --nvme --mac 12:9c:e5:86:26:6c; reset
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
