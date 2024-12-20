import Foundation
import Virtualization

final class StartSubcommand {
  private let name: String
  private let cpu: UInt8
  private let ram: UInt64
  private let mac: String?
  private let nvme: Bool

  init(name: String, cpu: UInt8, ram: UInt64, mac: String?, nvme: Bool) {
    self.name = name
    self.cpu = cpu
    self.ram = ram
    self.mac = mac
    self.nvme = nvme
  }

  func run() {
    let configuration = VZVirtualMachineConfiguration()
    let platform = VZGenericPlatformConfiguration()
    let bootloader = VZEFIBootLoader()
    let disksArray = NSMutableArray()

    platform.machineIdentifier = retrieveMachineIdentifier(name: name)
    bootloader.variableStore = retrieveEFIVariableStore(name: name)

    configuration.platform = platform
    configuration.bootLoader = bootloader
    configuration.cpuCount = Int(cpu)
    configuration.memorySize = ram * 1048576

    disksArray.add(createBlockDeviceConfiguration(name: name, nvme: nvme))

    guard let disks = disksArray as? [VZStorageDeviceConfiguration] else {
      fatalError("Invalid disks array.")
    }
    configuration.storageDevices = disks
    configuration.serialPorts = [ createConsoleConfiguration() ]
    configuration.networkDevices = [ createNetworkDeviceConfiguration(mac: mac) ]
    configuration.entropyDevices = [VZVirtioEntropyDeviceConfiguration()]

    do {
      try configuration.validate()
    } catch {
      fatalError(error.localizedDescription)
    }

    let virtualMachine = VZVirtualMachine(configuration: configuration)

    let delegate = Delegate()
    virtualMachine.delegate = delegate

    signal(SIGINT, trap)
    print("Booting virtual machine...")
    virtualMachine.start { (result) in
      if case let .failure(error) = result {
        fatalError(error.localizedDescription)
      }
    }

    RunLoop.main.run(until: Date.distantFuture)
  }
}
