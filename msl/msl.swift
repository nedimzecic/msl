import Foundation
import ArgumentParser

@main
struct MSL: ParsableCommand {
  static let configuration = CommandConfiguration(
    subcommands: [Install.self, List.self, Start.self]
  )
}

struct Install: ParsableCommand {
  @Option(help: "Virtual machine name")
  var name: String

  @Option(help: "Number of CPUs VM will use")
  var cpu: UInt8 = 2

  @Option(help: "RAM size in MB")
  var ram: UInt64 = 512

  @Option(help: "Disk size in GB")
  var disk: UInt8 = 16

  @Option(help: "Network device MAC address")
  var mac: String?

  @Flag(help: "Create storage as NVME storage device")
  var nvme = false

  @Option(help: "Path to ISO image")
  var iso: String

  func run() throws {
    let list = InstallSubcommand(name: name, cpu: cpu, ram: ram, disk: disk, mac: mac, nvme: nvme, iso: iso)
    list.run()
  }
}

struct List: ParsableCommand {
  func run() throws {
    let install = ListSubcommand()
    install.run()
  }
}

struct Start: ParsableCommand {
  @Option(help: "Virtual machine name")
  var name: String

  @Option(help: "Number of CPUs VM will use")
  var cpu: UInt8 = 2

  @Option(help: "RAM size in MB")
  var ram: UInt64 = 512

  @Option(help: "Network device MAC address")
  var mac: String?

  @Flag(help: "Create storage as NVME storage device")
  var nvme = false

  func run() throws {
    let start = StartSubcommand(name: name, cpu: cpu, ram: ram, mac: mac, nvme: nvme)
    start.run()
  }
}
