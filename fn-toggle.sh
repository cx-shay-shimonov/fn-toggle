#!/bin/bash

# Complete Fn key toggle script
# Toggles between standard function keys (F1-F12) and multimedia keys

# ============================================================================
# CONFIGURATION
# ============================================================================

# Timing delays
DELAY_PROCESS_CLEANUP=0.5        # Wait after killing System Settings for clean restart
DELAY_SETTINGS_ACTIVATION=0.5    # Wait for System Settings to become responsive
DELAY_SEARCH_RESULTS=0.5         # Wait for search results to populate
DELAY_NAVIGATION=0.2             # Wait between arrow key navigation steps
DELAY_DIALOG_OPEN=0.6            # Wait for Function Keys dialog to fully load (critical)

# Retry settings
MAX_RETRIES=3                    # Maximum retry attempts before giving up
RETRY_DELAY=0.2                  # Wait between retry attempts

# Sound feedback
SOUND_SUCCESS="/System/Library/Sounds/Tink.aiff"    # Success sound
SOUND_FAILURE="/System/Library/Sounds/Basso.aiff"   # Failure sound

# ============================================================================
# MAIN TOGGLE FUNCTION
# ============================================================================

toggle_fn_keys() {
    echo "🧹 Checking for System Settings process..."
    if killall "System Settings" 2>/dev/null; then
        echo "   ✓ System Settings was running, killed successfully"
        echo "   ⏳ Waiting ${DELAY_PROCESS_CLEANUP}s for clean restart..."
        sleep $DELAY_PROCESS_CLEANUP
    else
        echo "   ✓ System Settings was not running, no cleanup needed"
    fi

    osascript <<END
-- Open System Settings and navigate to Function Keys dialog
log "🚀 Activating System Settings"
tell application "System Settings"
    activate
end tell

log "⏳ Waiting ${DELAY_SETTINGS_ACTIVATION}s for System Settings..."
delay $DELAY_SETTINGS_ACTIVATION

tell application "System Events"
    tell process "System Settings"
        log "🔍 Searching for Function Keys"
        -- Search for Function Keys
        keystroke "f" using command down
        keystroke "function keys"
        log "⏳ Waiting ${DELAY_SEARCH_RESULTS}s for search results..."
        delay $DELAY_SEARCH_RESULTS
        
        log "⌨️  Navigating with arrow keys"
        -- Navigate to second search result

        keystroke (ASCII character 31) -- down arrow

        log "⏳ Waiting ${DELAY_NAVIGATION}s..."
        delay $DELAY_NAVIGATION
        keystroke (ASCII character 31) -- down arrow
        log "⏳ Waiting ${DELAY_DIALOG_OPEN}s for Function Keys dialog..."
        delay $DELAY_DIALOG_OPEN
        log "✅ Dialog delay completed"
        
        -- Toggle the checkbox
        log "🎯 Attempting to access Function Keys dialog UI elements"
        try
            log "→ Step 1: Accessing sheet 1 of window 1"
            tell sheet 1 of window 1
                log "→ Step 2: Accessing group 1 (main content)"
                tell group 1
                    log "→ Step 3: Accessing splitter group 1 (split view)"
                    tell splitter group 1
                        log "→ Step 4: Accessing group 2 (right panel)"
                        tell group 2
                            log "→ Step 5: Accessing scroll area 1 (scrollable content)"
                            tell scroll area 1
                                log "→ Step 6: Accessing group 1 (keyboard settings)"
                                tell group 1
                                    log "→ Step 7: Reading checkbox 1 current value"
                                    set currentValue to value of checkbox 1
                                    log "📊 Current state: " & currentValue
                                    
                                    log "→ Step 8: Clicking checkbox 1"
                                    click checkbox 1
                                    
                                    log "→ Step 9: Reading checkbox 1 new value"
                                    set newValue to value of checkbox 1
                                    log "📊 New state: " & newValue
                                    
                                    if newValue = 0 then
                                        log "✅ Toggled to: Multimedia keys (F1=brightness, F2=volume, etc.)"
                                    else
                                        log "✅ Toggled to: Standard function keys (F1, F2, F3, etc.)"
                                    end if
                                    log "🎉 SUCCESS: Checkbox toggle completed"
                                end tell
                            end tell
                        end tell
                    end tell
                end tell
            end tell
        on error errMsg
            log "❌ ERROR: Failed to access or toggle checkbox"
            log "❌ Error message: " & errMsg
            log "💡 TIP: This usually means the dialog wasn't fully loaded or UI structure changed"
        end try
    end tell
end tell

log "🚪 Quitting System Settings"
tell application "System Settings" to quit

END
}

# ============================================================================
# RETRY LOGIC
# ============================================================================

echo "🎬 === SCRIPT START: Fn key toggle initiated ==="
echo "Toggling Fn key behavior..."
echo ""

attempt=1
success=false

while [ $attempt -le $MAX_RETRIES ]; do
    if [ $attempt -gt 1 ]; then
        echo ""
        echo "🔄 RETRY: Attempt $attempt of $MAX_RETRIES"
        echo ""
    else
        echo "▶️  ATTEMPT: #$attempt of $MAX_RETRIES"
        echo ""
    fi
    
    output=$(toggle_fn_keys 2>&1)
    
    # Success if we accessed the dialog (output contains "Current state:")
    if echo "$output" | grep -q "Current state:"; then
        success=true
        echo ""
        echo "✅ SUCCESS: Checkbox was accessed and toggled!"
        echo "🏁 === SCRIPT END: Completed successfully on attempt $attempt ==="
        echo ""
        echo "✓ Done! Fn key behavior toggled."
        echo ""
        echo "Test your Mac's built-in keyboard:"
        echo "Press F1, F2, F3, etc. without holding Fn"
        echo ""
        echo "Changes take effect immediately!"
        echo ""
        afplay "$SOUND_SUCCESS" &
        break
    else
        echo "❌ FAILED: Checkbox was NOT accessed on attempt $attempt"
        
        # Detailed failure analysis
        if echo "$output" | grep -q "Error toggling checkbox"; then
            echo "💡 Analysis: AppleScript error occurred - likely UI timing or structure issue"
            
            if [ $attempt -lt $MAX_RETRIES ]; then
                echo "⏳ Retrying after ${RETRY_DELAY}s delay..."
                sleep $RETRY_DELAY
            fi
        else
            echo "❌ CRITICAL: Unexpected failure - check Accessibility permissions"
            echo "🛑 === SCRIPT END: Failed - permission or configuration issue ==="
            echo ""
            echo "✗ Failed. Make sure Accessibility permissions are granted."
            echo "$output"
            echo ""
            break
        fi
    fi
    
    attempt=$((attempt + 1))
done

# Final failure message if all retries exhausted
if [ "$success" = false ]; then
    if [ $attempt -gt $MAX_RETRIES ]; then
        echo ""
        echo "✗ Failed after $MAX_RETRIES attempts."
        echo "Try increasing DELAY_DIALOG_OPEN in the script configuration."
        echo ""
    fi
    afplay "$SOUND_FAILURE" &
    exit 1
fi
