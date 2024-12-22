import Virtualization

var windel: NSWindowDelegate?

func OpenWindow(virtualMachine: VZVirtualMachine, name: String) {
  NSApplication.shared.setActivationPolicy(.regular)
  let window = NSWindow(
    contentRect: NSMakeRect(0, 0, 1024, 768),
    styleMask: [.titled, .closable, .miniaturizable, .resizable],
    backing: .buffered,
    defer: true
  )
  window.collectionBehavior = .primary
  window.title = name
  window.center()
  

  class Delegate: NSObject, NSWindowDelegate {
    var virtualMachine: VZVirtualMachine
    init(virtualMachine: VZVirtualMachine) {
      self.virtualMachine = virtualMachine
    }

    func windowWillResize(_ sender: NSWindow, to: NSSize) -> NSSize {
      let contentSize = sender.contentRect(forFrameRect: NSRect(origin: NSZeroPoint, size: to)).size
      try! virtualMachine.graphicsDevices[0].displays[0].reconfigure(sizeInPixels: contentSize)
      return to
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
      _ = try? virtualMachine.requestStop()
      return false
    }
  }
  windel = Delegate(virtualMachine: virtualMachine)
  window.delegate = windel

  let view = VZVirtualMachineView()
  view.virtualMachine = virtualMachine
  window.contentView = view

  window.makeKeyAndOrderFront(Optional<NSObject>.none)

  NSApp.run()
}
