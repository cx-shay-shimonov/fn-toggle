on run
    tell application "System Settings"
        activate
    end tell

    delay 3

    tell application "System Events"
        tell process "System Settings"
            set mainWindow to window 1

            -- Step 1: Search for Function Keys setting
            keystroke "f" using command down
            delay 0.5

            keystroke "function keys"
            delay 1.5

            -- Navigate to second result
            keystroke (ASCII character 31) -- down arrow to first result
            delay 0.3
            keystroke (ASCII character 31) -- down arrow to second result
            delay 0.3

            -- Press enter to open the settings sheet
            keystroke (ASCII character 36) -- return key
            delay 2.0

            -- Step 2: Find and toggle the checkbox
            try
                set sheetElement to sheet 1 of mainWindow

                -- Search for the checkbox with the known name
                set allElements to entire contents of sheetElement
                set targetCheckbox to missing value

                repeat with elem in allElements
                    try
                        if (role of elem) is "AXCheckBox" then
                            set elemName to (name of elem as string)
                            if elemName contains "F1, F2" or elemName contains "standard function" then
                                set targetCheckbox to elem
                                exit repeat
                            end if
                        end if
                    end try
                end repeat

                if targetCheckbox is not missing value then
                    -- Get current state before toggle
                    set currentValue to value of targetCheckbox
                    log "Current state: " & currentValue

                    -- Click to toggle
                    click targetCheckbox
                    delay 0.5

                    -- Get new state after toggle
                    set newValue to value of targetCheckbox
                    log "New state: " & newValue

                    if newValue = 0 then
                        log "Switched to: Multimedia keys by default"
                    else
                        log "Switched to: Standard function keys (F1-F12)"
                    end if
                else
                    log "Error toggling checkbox: checkbox not found in sheet"
                end if
            on error errMsg
                log "Error toggling checkbox: " & errMsg
            end try
        end tell
    end tell

    -- Close System Settings
    tell application "System Settings" to quit
end run
