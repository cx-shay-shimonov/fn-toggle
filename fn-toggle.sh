#!/bin/bash

# Complete Fn key toggle script
# Toggles between standard function keys (F1-F12) and multimedia keys

# ============================================================================
# CONFIGURATION
# ============================================================================
# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Retry settings
MAX_RETRIES=3                    # Maximum number of attempts before giving up
RETRY_DELAY=0.2                  # Seconds to wait between retry attempts

# Debug mode: leave System Settings open if toggle fails (for inspection)
DEBUG_KEEP_OPEN=false

# Sound feedback
SOUND_SUCCESS="/System/Library/Sounds/Funk.aiff"    # Play on successful toggle
SOUND_FAILURE="/System/Library/Sounds/Glass.aiff"   # Play on failure

# ============================================================================
# MAIN TOGGLE FUNCTION
# ============================================================================
toggle_fn_keys() {
    # Close System Settings to start fresh
    killall "System Settings" 2>/dev/null
    sleep 1

    # Call the standalone AppleScript file which works reliably
    osascript "$SCRIPT_DIR/../toggle_helper.applescript"
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
    # (indicates the script successfully found and toggled the checkbox)
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
                echo "⚠ Attempt $attempt failed. Retrying..."
                sleep $RETRY_DELAY
            else
                # Last attempt failed, keep System Settings open for debugging if enabled
                if [ "$DEBUG_KEEP_OPEN" = true ]; then
                    echo "⚠ DEBUG: Keeping System Settings open so you can inspect the failure."
                    echo "Output from last attempt:"
                    echo "$output"
                fi
            fi
        else
            # Different error - might be permissions or other issue
            echo "✗ Failed. Make sure Accessibility permissions are granted."
            echo "$output"
            if [ "$DEBUG_KEEP_OPEN" = true ]; then
                echo "⚠ DEBUG: System Settings left open for inspection."
            fi
            break
        fi
    fi

    attempt=$((attempt + 1))
done

# Final failure message if all retries exhausted
if [ "$success" = false ]; then
    if [ $attempt -gt $MAX_RETRIES ]; then
        echo "✗ Failed after $MAX_RETRIES attempts."
        afplay "$SOUND_FAILURE" &  # Play failure sound in background
    fi
    exit 1
fi
