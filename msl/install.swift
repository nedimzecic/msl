import Foundation
import Virtualization

final class InstallSubcommand {
  private let name: String
  private let cpu: UInt8
  private let ram: UInt64
  private let disk: UInt8
  private let mac: String?
  private let nvme: Bool
  private let iso: String

  init(name: String, cpu: UInt8, ram: UInt64, disk: UInt8, mac: String?, nvme: Bool, iso: String) {
    self.name = name
    self.cpu = cpu
    self.ram = ram
    self.disk = disk
    self.mac = mac
    self.nvme = nvme
    self.iso = iso
  }

  func run() {
    let configuration = VZVirtualMachineConfiguration()
    let platform = VZGenericPlatformConfiguration()
    let bootloader = VZEFIBootLoader()
    let disksArray = NSMutableArray()

    createVMBundle(name: name)
    createMainDiskImage(name: name, disk: disk)

    platform.machineIdentifier = createAndSaveMachineIdentifier(name: name)
    bootloader.variableStore = createEFIVariableStore(name: name)

    configuration.platform = platform
    configuration.bootLoader = bootloader
    configuration.cpuCount = Int(cpu)
    configuration.memorySize = ram * 1048576

    disksArray.add(createUSBMassStorageDeviceConfiguration(iso: iso))
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
