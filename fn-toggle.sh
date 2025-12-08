#!/bin/bash

# Complete Fn key toggle script
# Toggles between standard function keys (F1-F12) and multimedia keys

# ============================================================================
# CONFIGURATION
# ============================================================================
# Timing delays ordered by execution flow - optimized for speed and stability
# Delays match the sequence: cleanup → activation → search → navigation → dialog

# Process cleanup
DELAY_PROCESS_CLEANUP=1.0        # Wait after killing System Settings for clean restart

# System Settings activation
DELAY_SETTINGS_ACTIVATION=0.5    # Wait for System Settings to become responsive

# Search and navigation
DELAY_SEARCH_RESULTS=0.5         # Wait for search results to populate
DELAY_NAVIGATION=0.2             # Wait between arrow key navigation steps

# Dialog operations
DELAY_DIALOG_OPEN=0.8            # Wait for Function Keys dialog to fully load (critical)

# Retry settings
MAX_RETRIES=3                    # Maximum retry attempts before giving up
RETRY_DELAY=0.2                  # Wait between retry attempts

# Sound feedback
SOUND_SUCCESS="/System/Library/Sounds/Tink.aiff"    # Success sound
SOUND_FAILURE="/System/Library/Sounds/Basso.aiff"   # Failure sound

# ============================================================================

# ============================================================================
# MAIN TOGGLE FUNCTION
# ============================================================================
toggle_fn_keys() {
    killall "System Settings" 2>/dev/null
    sleep $DELAY_PROCESS_CLEANUP

    osascript <<END
-- Open System Settings and navigate to Function Keys dialog
tell application "System Settings"
    activate
end tell

delay $DELAY_SETTINGS_ACTIVATION

tell application "System Events"
    tell process "System Settings"
        -- Search for Function Keys
        keystroke "f" using command down
        keystroke "function keys"
        delay $DELAY_SEARCH_RESULTS
        
        -- Navigate to second search result
        keystroke (ASCII character 31) -- down arrow
        delay $DELAY_NAVIGATION
        keystroke (ASCII character 31) -- down arrow
        delay $DELAY_NAVIGATION
        delay $DELAY_DIALOG_OPEN
        
        -- Toggle the checkbox
        try
            tell sheet 1 of window 1
                tell group 1
                    tell splitter group 1
                        tell group 2
                            tell scroll area 1
                                tell group 1
                                    set currentValue to value of checkbox 1
                                    log "Current state: " & currentValue
                                    
                                    click checkbox 1
                                    
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

tell application "System Settings" to quit

END
}

# ============================================================================
# RETRY LOGIC
# ============================================================================
echo "Toggling Fn key behavior..."

attempt=1
success=false

while [ $attempt -le $MAX_RETRIES ]; do
    if [ $attempt -gt 1 ]; then
        echo "⟳ Retry attempt $attempt of $MAX_RETRIES..."
    fi
    
    output=$(toggle_fn_keys 2>&1)
    
    # Success if we accessed the dialog (output contains "Current state:")
    if echo "$output" | grep -q "Current state:"; then
        success=true
        echo "✓ Done! Fn key behavior toggled."
        echo ""
        echo "Test your Mac's built-in keyboard:"
        echo "Press F1, F2, F3, etc. without holding Fn"
        echo ""
        echo "Changes take effect immediately!"
        afplay "$SOUND_SUCCESS" &
        break
    else
        if echo "$output" | grep -q "Error toggling checkbox"; then
            if [ $attempt -lt $MAX_RETRIES ]; then
                echo "⚠ Attempt $attempt failed (timing issue). Retrying..."
                sleep $RETRY_DELAY
            fi
        else
            echo "✗ Failed. Make sure Accessibility permissions are granted."
            echo "$output"
            break
        fi
    fi
    
    attempt=$((attempt + 1))
done

# Final failure message if all retries exhausted
if [ "$success" = false ]; then
    if [ $attempt -gt $MAX_RETRIES ]; then
        echo "✗ Failed after $MAX_RETRIES attempts."
        echo "Try increasing DELAY_DIALOG_OPEN in the script configuration."
        afplay "$SOUND_FAILURE" &
    fi
    exit 1
fi

