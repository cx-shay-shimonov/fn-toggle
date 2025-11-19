# Mac Fn Key Toggle

A command-line tool to toggle the behavior of function keys on your MacBook Pro M4.

## ✅ Working Solution

This tool successfully toggles between:
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
5. Changes take effect immediately!

**To test:**
- Press F1, F2, F3, etc. on your Mac's built-in keyboard (without holding Fn)
- The behavior should have changed

**Optional - Add to PATH:**

Create an alias in your `~/.zshrc`:
```bash
alias fn-toggle='/Users/shayshimonov/Projects/fn-toggle/fn-toggle.sh'
```

Then you can run `fn-toggle` from anywhere!

## How It Works

The script uses AppleScript with UI automation to:
1. Search for "Function Keys" in System Settings
2. Open the Function Keys dialog
3. Click the checkbox at path: `sheet 1 → group 1 → splitter group 1 → group 2 → scroll area 1 → group 1 → checkbox 1`
4. The toggle happens instantly without needing to restart or log out

## Technical Details

The checkbox state:
- `1` = Standard function keys (F1-F12)
- `0` = Multimedia keys by default

The script also updates the underlying preferences:
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
