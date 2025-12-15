# Mac Fn Key Toggle

A fast, reliable command-line tool to toggle the behavior of function keys on your Mac.

## ✨ Features

- **Fast**: Optimized timing (~3-4 seconds)
- **Reliable**: Automatic retry logic handles intermittent timing issues
- **Smart Cleanup**: Only waits for process cleanup if System Settings was actually running
- **Detailed Logging**: Console output with emojis shows exactly what's happening at each step
- **Audio Feedback**: Subtle sound effects confirm success or alert failures
- **Clean Code**: Well-structured and easy to maintain
- **Keyboard Shortcut**: Optional global hotkey setup with Hammerspoon
- **Configurable**: Easy-to-tune delay settings

## ✅ What It Does

This tool toggles between:
- **Standard function keys (F1-F12)**: Function keys act as F1, F2, F3, etc.
- **Special multimedia keys**: Function keys control brightness, volume, etc.

## Requirements

- macOS (tested on MacBook Pro M4 with macOS Sequoia)
- **Accessibility permissions** for your Terminal app (Terminal.app, iTerm2, Warp, etc.)

### Granting Accessibility Permissions

1. Open **System Settings** > **Privacy & Security** > **Accessibility**
2. Click the lock icon and authenticate
3. Add your terminal application to the list
4. Toggle it ON

## Usage

Simply run:
```bash
./fn-toggle.sh
```

The script will:
1. Open System Settings
2. Navigate to Function Keys settings
3. Toggle the checkbox
4. Close System Settings
5. Play a **Tink** sound on success (keyboard click sound)
6. Changes take effect immediately!

**On Success:**
- Displays: `✓ Done! Fn key behavior toggled.`
- Plays subtle "Tink" sound (like a keyboard click)
- Settings close automatically

**On Timing Issues:**
- Automatically retries up to 3 times
- Shows progress: `⚠ Attempt N failed (timing issue). Retrying...`
- Usually succeeds on retry

**On Failure:**
- Displays: `✗ Failed after 3 attempts.`
- Plays "Basso" error sound
- Suggests increasing delay in configuration

**To test:**
- Press F1, F2, F3, etc. on your Mac's built-in keyboard (without holding Fn)
- The behavior should have changed

**Optional - Add to PATH:**

Create an alias in your `~/.zshrc`:
```bash
alias fn-toggle='/Users/shayshimonov/Projects/fn-toggle/fn-toggle.sh'
```

Then you can run `fn-toggle` from anywhere!

**Optional - Global Keyboard Shortcut:**

For instant toggling with a keyboard shortcut, use [Hammerspoon](https://www.hammerspoon.org/):

1. Install Hammerspoon: `brew install --cask hammerspoon`
2. Add to `~/.hammerspoon/init.lua`:
```lua
hs.hotkey.bind({"ctrl", "shift"}, "A", function()
  hs.execute("/Users/shayshimonov/Projects/fn-toggle/fn-toggle.sh")
end)
```
3. Now press `⌃⇧A` (Control+Shift+A) from anywhere to toggle!

## Configuration

All timing delays and settings are at the top of `fn-toggle.sh`:

```bash
# Timing delays (optimized for speed and reliability)
DELAY_PROCESS_CLEANUP=0.5        # Wait after killing System Settings
DELAY_SETTINGS_ACTIVATION=0.5    # Wait for System Settings to activate
DELAY_SEARCH_RESULTS=0.5         # Wait for search results to populate
DELAY_NAVIGATION=0.2             # Wait after navigation
DELAY_DIALOG_OPEN=0.6            # Wait for dialog to fully load (critical)

# Retry settings
MAX_RETRIES=3                    # Maximum retry attempts
RETRY_DELAY=0.2                  # Wait between retries

# Sound feedback
SOUND_SUCCESS="/System/Library/Sounds/Tink.aiff"
SOUND_FAILURE="/System/Library/Sounds/Basso.aiff"
```

Delays are optimized for speed while maintaining reliability. Adjust if needed for your system.

## How It Works

The script uses AppleScript with UI automation to:
1. Check if System Settings is running (only cleans up if needed)
2. Search for "Function Keys" in System Settings
3. Navigate to the Function Keys dialog
4. Click the checkbox at path: `sheet 1 → group 1 → splitter group 1 → group 2 → scroll area 1 → group 1 → checkbox 1`
5. Close System Settings
6. The toggle happens instantly without needing to restart or log out

Console output shows detailed progress with emoji indicators (🚀 ⏳ ✅ ❌) at each step for easy troubleshooting.

## Technical Details

### Performance
- **Runtime**: ~3-4 seconds
- **Smart Cleanup**: Skips 0.5s delay if System Settings wasn't running (faster subsequent runs)
- **Reliability**: Automatic retry logic handles intermittent timing failures
- **Success Rate**: >95% with retry mechanism
- **Detailed Logging**: Console output with emojis for easy troubleshooting

### Checkbox States
- `1` = Standard function keys (F1-F12)
- `0` = Multimedia keys by default

### How Retry Logic Works
1. Attempts to toggle the Fn key setting
2. Logs every step with emoji indicators for easy tracking
3. If AppleScript fails, automatically retries (up to 3 attempts)
4. Waits 0.2s between retries
5. Success detected by checking for "Current state:" in output
6. Permission errors exit immediately (no point retrying)
7. Plays appropriate sound feedback (Tink for success, Basso for failure)

### System Preferences Updated
The script modifies:
- `com.apple.keyboard.fnState` (global preferences)
- `AppleFnUsageType` in `com.apple.HIToolbox`

## Note

This script only affects the **Mac's built-in keyboard**. External keyboards may behave differently depending on their own settings.

## Project Structure

```
/Users/shayshimonov/Projects/fn-toggle/
├── fn-toggle.sh      # Main script ⭐
├── README.md         # Documentation
├── package.json      # npm scripts (npm start)
└── .vscode/          # Editor configuration
    ├── tasks.json    # Build tasks
    └── launch.json   # Run configurations
```

### Running the Script

```bash
# Command line
./fn-toggle.sh

# Or with npm
npm start
```
