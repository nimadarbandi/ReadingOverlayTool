import Cocoa
import Carbon

final class HotKeyManager {
    var onHotKey: (() -> Void)?
    var onToggleVisibility: (() -> Void)?

    private var hotKeyRef: EventHotKeyRef?
    private var visibilityHotKeyRef: EventHotKeyRef?
    private var handlerRef: EventHandlerRef?

    func start() {
        let hotKeyID = EventHotKeyID(signature: OSType(0x424B4D4B), id: 1)
        let modifierFlags = UInt32(cmdKey | shiftKey)
        RegisterEventHotKey(UInt32(kVK_ANSI_Z), modifierFlags, hotKeyID, GetEventDispatcherTarget(), 0, &hotKeyRef)

        let visibilityHotKeyID = EventHotKeyID(signature: OSType(0x424B4D4B), id: 2)
        let visibilityFlags = UInt32(cmdKey | shiftKey | controlKey)
        RegisterEventHotKey(UInt32(kVK_ANSI_Z), visibilityFlags, visibilityHotKeyID, GetEventDispatcherTarget(), 0, &visibilityHotKeyRef)

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let handler: EventHandlerUPP = { _, event, userData in
            guard let event = event, let userData = userData else { return noErr }
            var hotKeyID = EventHotKeyID()
            let status = GetEventParameter(
                event,
                EventParamName(kEventParamDirectObject),
                EventParamType(typeEventHotKeyID),
                nil,
                MemoryLayout<EventHotKeyID>.size,
                nil,
                &hotKeyID
            )
            if status == noErr && hotKeyID.id == 1 {
                let manager = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()
                manager.onHotKey?()
            } else if status == noErr && hotKeyID.id == 2 {
                let manager = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()
                manager.onToggleVisibility?()
            }
            return noErr
        }

        let userData = Unmanaged.passUnretained(self).toOpaque()
        InstallEventHandler(GetEventDispatcherTarget(), handler, 1, &eventType, userData, &handlerRef)
    }

    func stop() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        if let visibilityHotKeyRef {
            UnregisterEventHotKey(visibilityHotKeyRef)
            self.visibilityHotKeyRef = nil
        }
        if let handlerRef {
            RemoveEventHandler(handlerRef)
            self.handlerRef = nil
        }
    }
}
