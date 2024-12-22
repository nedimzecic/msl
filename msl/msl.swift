import Foundation
import ArgumentParser

@main
struct MSL: ParsableCommand {
  @Option(help: "Virtual machine name")
  var name: String

  @Option(help: "Number of CPUs VM will use")
  var cpu: UInt8 = 2

  @Option(help: "RAM size in MB")
  var ram: UInt64 = 512

  @Option(help: "Disk size in GB")
  var disk: UInt8 = 16

  @Flag(help: "Create storage as NVME storage device")
  var nvme = false

  @Option(help: "Network device MAC address")
  var mac: String?

  @Flag(help: "Create virtio graphics device")
  var graphics = false

  @Option(help: "Path to ISO image")
  var iso: String?

  func run() throws {
    let vm = VirtualMachine(name: name, cpu: cpu, ram: ram, disk: disk, nvme: nvme, mac: mac, graphics: graphics, iso: iso)
    vm.run()
  }
}
