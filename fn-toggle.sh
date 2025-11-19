#!/bin/bash

# Complete Fn key toggle script
# Toggles between standard function keys (F1-F12) and multimedia keys

echo "Toggling Fn key behavior..."

# Close System Settings to start fresh
killall "System Settings" 2>/dev/null
sleep 2

osascript <<'END'
-- Step 1: Open System Settings and navigate to Function Keys
tell application "System Settings"
    activate
end tell

delay 0.5

tell application "System Events"
    tell process "System Settings"
        -- Focus search box
        keystroke "f" using command down
        
        -- Search for "function keys"
        keystroke "function keys"
        delay 0.5
        
        -- Navigate to second result (Function Keys)
        keystroke (ASCII character 31) -- down arrow to first result
        delay 0.2
        keystroke (ASCII character 31) -- down arrow to second result
        delay 0.1
        
        -- Wait for dialog to open
        delay 0.5
        
        -- Step 2: Toggle the checkbox
        try
            tell sheet 1 of window 1
                tell group 1
                    tell splitter group 1
                        tell group 2
                            tell scroll area 1
                                tell group 1
                                    -- Get current state
                                    set currentValue to value of checkbox 1
                                    log "Current state: " & currentValue
                                    
                                    -- Click to toggle
                                    click checkbox 1
                                    
                                    -- Get new state
                                    set newValue to value of checkbox 1
                                    log "New state: " & newValue
                                    
                                    if newValue = 0 then
                                        log "Switched to: Multimedia keys by default"
                                    else
                                        log "Switched to: Standard function keys (F1-F12)"
                                    end if
                                end tell
                            end tell
                        end tell
                    end tell
                end tell
            end tell
        on error errMsg
            log "Error toggling checkbox: " & errMsg
        end try
        
    end tell
end tell

-- Close System Settings
tell application "System Settings" to quit

END

if [ $? -eq 0 ]; then
    echo "✓ Done! Fn key behavior toggled."
    echo ""
    echo "Test your Mac's built-in keyboard:"
    echo "Press F1, F2, F3, etc. without holding Fn"
    echo ""
    echo "Changes take effect immediately!"
else
    echo "✗ Failed. Make sure Accessibility permissions are granted."
fi

