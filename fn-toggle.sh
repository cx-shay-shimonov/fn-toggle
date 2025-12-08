#!/bin/bash

# Complete Fn key toggle script
# Toggles between standard function keys (F1-F12) and multimedia keys

# ============================================================================
# CONFIGURATION
# ============================================================================
# All timing delays and retry settings are stored here for easy tuning and maintenance
# Delays are optimized for speed while maintaining stability (tested with 10-test suite)

# Retry settings
MAX_RETRIES=3                    # Maximum number of attempts before giving up
RETRY_DELAY=0.2                  # Seconds to wait between retry attempts (optimized via testing)

# Sound feedback
SOUND_SUCCESS="/System/Library/Sounds/Tink.aiff"    # Play on successful toggle (keyboard click sound)
SOUND_FAILURE="/System/Library/Sounds/Basso.aiff"   # Play on failure (classic error sound)

# Process initialization
DELAY_PROCESS_CLEANUP=2          # Time to wait after killing System Settings (allows clean restart)

# System Settings activation
DELAY_SETTINGS_ACTIVATION=0.5    # Time for System Settings to fully activate and become responsive

# Search and navigation
DELAY_SEARCH_RESULTS=0.5         # Time for search results to populate after typing query
DELAY_FIRST_NAVIGATION=0.2       # Time between first arrow down navigation
DELAY_SECOND_NAVIGATION=0.1      # Time between second arrow down navigation

# Dialog operations
DELAY_DIALOG_OPEN=0.8            # Critical: Time for Function Keys dialog sheet to fully load

# ============================================================================

# ============================================================================
# MAIN TOGGLE FUNCTION
# ============================================================================
toggle_fn_keys() {
    # Close System Settings to start fresh
    killall "System Settings" 2>/dev/null
    sleep $DELAY_PROCESS_CLEANUP

    osascript <<END
-- Step 1: Open System Settings and navigate to Function Keys
tell application "System Settings"
    activate
end tell

delay $DELAY_SETTINGS_ACTIVATION

tell application "System Events"
    tell process "System Settings"
        -- Focus search box
        keystroke "f" using command down
        
        -- Search for "function keys"
        keystroke "function keys"
        delay $DELAY_SEARCH_RESULTS
        
        -- Navigate to second result (Function Keys)
        keystroke (ASCII character 31) -- down arrow to first result
        delay $DELAY_FIRST_NAVIGATION
        keystroke (ASCII character 31) -- down arrow to second result
        delay $DELAY_SECOND_NAVIGATION
        
        -- Wait for dialog to open
        delay $DELAY_DIALOG_OPEN
        
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
    
    # Run the toggle function and capture output
    output=$(toggle_fn_keys 2>&1)
    exit_code=$?
    
    # Check if successful by looking for "Current state:" in output
    # (indicates the script successfully accessed the dialog)
    if echo "$output" | grep -q "Current state:"; then
        success=true
        echo "✓ Done! Fn key behavior toggled."
        echo ""
        echo "Test your Mac's built-in keyboard:"
        echo "Press F1, F2, F3, etc. without holding Fn"
        echo ""
        echo "Changes take effect immediately!"
        afplay "$SOUND_SUCCESS" &  # Play success sound in background
        break
    else
        # Check if it's an error we should retry
        if echo "$output" | grep -q "Error toggling checkbox"; then
            if [ $attempt -lt $MAX_RETRIES ]; then
                echo "⚠ Attempt $attempt failed (timing issue). Retrying..."
                sleep $RETRY_DELAY
            fi
        else
            # Different error - might be permissions
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
        afplay "$SOUND_FAILURE" &  # Play failure sound in background
    fi
    exit 1
fi

