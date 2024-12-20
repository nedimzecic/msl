import Foundation
import Virtualization

let mslPath = "\(NSHomeDirectory())/.msl"

class Delegate: NSObject {
}

extension Delegate: VZVirtualMachineDelegate {
  func guestDidStop(_ virtualMachine: VZVirtualMachine) {
    print("The guest shut down. Exiting.")
    exit(EXIT_SUCCESS)
  }
}

let trap: sig_t = { signal in
  print("Got signal: \(signal). Use poweroff command inside VM instead.")
}

func createVMBundle(name: String) {
  do {
    let path = "\(mslPath)/\(name).bundle"
    try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
  } catch {
    fatalError("Failed to create msl VM bundle directory.")
  }
}

func createAndSaveMachineIdentifier(name: String) -> VZGenericMachineIdentifier {
  let path = "\(mslPath)/\(name).bundle/machineid"
  let machineIdentifier = VZGenericMachineIdentifier()
  try! machineIdentifier.dataRepresentation.write(to: URL(fileURLWithPath: path))
  return machineIdentifier
}

func retrieveMachineIdentifier(name: String) -> VZGenericMachineIdentifier {
  let path = "\(mslPath)/\(name).bundle/machineid"
  guard let machineIdentifierData = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
    fatalError("Failed to retrieve the machine identifier data.")
  }

  guard let machineIdentifier = VZGenericMachineIdentifier(dataRepresentation: machineIdentifierData) else {
    fatalError("Failed to create the machine identifier.")
  }

  return machineIdentifier
}

func createEFIVariableStore(name: String) -> VZEFIVariableStore {
  let path = "\(mslPath)/\(name).bundle/nvram"
  guard let efiVariableStore = try? VZEFIVariableStore(creatingVariableStoreAt: URL(fileURLWithPath: path)) else {
    fatalError("Failed to create the EFI variable store.")
  }

  return efiVariableStore
}

func retrieveEFIVariableStore(name: String) -> VZEFIVariableStore {
  let path = "\(mslPath)/\(name).bundle/nvram"
  if !FileManager.default.fileExists(atPath: path) {
    fatalError("EFI variable store does not exist.")
  }

  return VZEFIVariableStore(url: URL(fileURLWithPath: path))
}

func createMainDiskImage(name: String, disk: UInt8) {
  let path = "\(mslPath)/\(name).bundle/rootfs.img"
  let diskCreated = FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
  if !diskCreated {
    fatalError("Failed to create main disk image.")
  }

  guard let mainDiskFileHandle = try? FileHandle(forWritingTo: URL(fileURLWithPath: path)) else {
    fatalError("Failed to get file handle for the main disk image.")
  }

  do {
    try mainDiskFileHandle.truncate(atOffset: UInt64(disk) * 1073741824)
  } catch {
    fatalError("Failed to truncate the main disk image.")
  }
}

func createBlockDeviceConfiguration(name: String, nvme: Bool) -> VZStorageDeviceConfiguration {
  let path = "\(mslPath)/\(name).bundle/rootfs.img"
  guard let mainDiskAttachment = try? VZDiskImageStorageDeviceAttachment(url: URL(fileURLWithPath: path), readOnly: false) else {
    fatalError("Failed to create main disk attachment.")
  }

  if nvme {
    return VZNVMExpressControllerDeviceConfiguration(attachment: mainDiskAttachment)
  }

  return VZVirtioBlockDeviceConfiguration(attachment: mainDiskAttachment)
}

func createUSBMassStorageDeviceConfiguration(iso: String) -> VZUSBMassStorageDeviceConfiguration {
  guard let intallerDiskAttachment = try? VZDiskImageStorageDeviceAttachment(url: URL(fileURLWithPath: iso), readOnly: true) else {
    fatalError("Failed to create installer's disk attachment.")
  }

  return VZUSBMassStorageDeviceConfiguration(attachment: intallerDiskAttachment)
}

func createConsoleConfiguration() -> VZSerialPortConfiguration {
  let consoleConfiguration = VZVirtioConsoleDeviceSerialPortConfiguration()

  let inputFileHandle = FileHandle.standardInput
  let outputFileHandle = FileHandle.standardOutput

  // Put stdin into raw mode, disabling local echo, input canonicalization,
  // and CR-NL mapping.
  var attributes = termios()
  tcgetattr(inputFileHandle.fileDescriptor, &attributes)
  attributes.c_iflag &= ~tcflag_t(ICRNL)
  attributes.c_lflag &= ~tcflag_t(ICANON | ECHO)
  tcsetattr(inputFileHandle.fileDescriptor, TCSANOW, &attributes)

  let stdioAttachment = VZFileHandleSerialPortAttachment(fileHandleForReading: inputFileHandle, fileHandleForWriting: outputFileHandle)
  consoleConfiguration.attachment = stdioAttachment

  return consoleConfiguration
}

func createNetworkDeviceConfiguration(mac: String?) -> VZNetworkDeviceConfiguration {
  let networkDevice = VZVirtioNetworkDeviceConfiguration()
  networkDevice.attachment = VZNATNetworkDeviceAttachment()
  networkDevice.macAddress = VZMACAddress(string: mac!) ?? VZMACAddress.randomLocallyAdministered()

  return networkDevice
}
