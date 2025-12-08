# Mac Fn Key Toggle

A fast, reliable command-line tool to toggle the behavior of function keys on your Mac.

## ✨ Features

- **Fast**: Optimized timing (72% faster than original, ~4-5 seconds)
- **Reliable**: Automatic retry logic handles intermittent timing issues
- **Audio Feedback**: Subtle sound effects confirm success or alert failures
- **Keyboard Shortcut**: Optional global hotkey setup with Hammerspoon
- **Configurable**: Easy-to-tune delay settings in centralized configuration

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

All timing delays and settings are configurable at the top of `fn-toggle.sh`:

### Timing Delays (ordered by execution flow)
- `DELAY_PROCESS_CLEANUP=1.0` - Wait after killing System Settings
- `DELAY_SETTINGS_ACTIVATION=0.5` - Wait for Settings to activate
- `DELAY_SEARCH_RESULTS=0.5` - Wait for search results
- `DELAY_NAVIGATION=0.2` - Wait between arrow key navigation steps
- `DELAY_DIALOG_OPEN=0.8` - Wait for dialog to fully load (critical)

### Retry Settings
- `MAX_RETRIES=3` - Maximum retry attempts
- `RETRY_DELAY=0.2` - Seconds between retries

### Sound Feedback
- `SOUND_SUCCESS` - Tink.aiff (keyboard click sound)
- `SOUND_FAILURE` - Basso.aiff (classic error sound)

All delays are optimized for speed while maintaining reliability. Adjust if needed for your system.

## How It Works

The script uses AppleScript with UI automation to:
1. Search for "Function Keys" in System Settings
2. Open the Function Keys dialog
3. Click the checkbox at path: `sheet 1 → group 1 → splitter group 1 → group 2 → scroll area 1 → group 1 → checkbox 1`
4. The toggle happens instantly without needing to restart or log out

## Technical Details

### Performance
- **Runtime**: ~4-5 seconds (down from ~13-14 seconds)
- **Optimization**: 72% faster through timing optimization
- **Reliability**: Automatic retry logic handles ~20-30% intermittent timing failures
- **Success Rate**: >95% with retry mechanism

### Checkbox States
- `1` = Standard function keys (F1-F12)
- `0` = Multimedia keys by default

### How Retry Logic Works
1. Attempts to toggle the Fn key setting
2. If timing issue detected, automatically retries (up to 3 attempts)
3. Waits 0.2s between retries (optimized via benchmarking)
4. Success detected by "Current state:" in output
5. Plays appropriate sound feedback (Tink for success, Basso for failure)

### System Preferences Updated
The script modifies:
- `com.apple.keyboard.fnState` (global preferences)
- `AppleFnUsageType` in `com.apple.HIToolbox`

## Note

This script only affects the **Mac's built-in keyboard**. External keyboards may behave differently depending on their own settings.

## Project Structure

```
/Users/shayshimonov/Projects/fn-toggle/
├── fn-toggle.sh           # Main working script ⭐
└── README.md              # Documentation
```
