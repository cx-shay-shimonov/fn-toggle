import Foundation
import Carbon

// Swift helper to switch keyboard input source to English using TIS (Text Input Services)
// Based on KeyboardGuard approach

func findInputSource(by identifier: String) -> TISInputSource? {
    let filter = [kTISPropertyInputSourceID: identifier] as CFDictionary
    guard let sourceList = TISCreateInputSourceList(filter, false)?.takeRetainedValue() as? [TISInputSource] else {
        return nil
    }
    return sourceList.first
}

func selectInputSource(_ source: TISInputSource) {
    let status = TISSelectInputSource(source)
    if status == noErr {
        print("Switched keyboard to English")
    } else {
        print("Failed to switch keyboard")
    }
}

// Switch to English keyboard
if let englishSource = findInputSource(by: "com.apple.keylayout.ABC") {
    selectInputSource(englishSource)
} else {
    print("English keyboard not found")
}
