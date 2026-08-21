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

The script uses a two-step approach to work reliably on any system language:

1. **Switch keyboard to English** (`switch_keyboard.swift`)
   - Uses Apple's Text Input Services (TIS) Carbon framework
   - Finds and activates the English (ABC) keyboard layout
   - Ensures keystrokes produce English characters regardless of system language

2. **Toggle Function Keys** (`toggle_helper.applescript`)
   - Opens System Settings with English keyboard active
   - Searches for "Function Keys" using keystrokes
   - Navigates to and opens the Function Keys dialog
   - Clicks the checkbox to toggle between Standard Function Keys and Multimedia Keys
   - The toggle happens instantly without needing to restart or log out

**Why this approach?**
The keystroke method (`keystroke "function keys"`) produces different characters when the keyboard layout is Hebrew, Arabic, or any non-English language. By switching to English keyboard first, we ensure the search text is produced correctly, allowing System Settings to find the setting and toggle it.

This approach is inspired by [KeyboardGuard](https://github.com/shayshimonov/KeyboardGuard), which uses the same TIS technique for keyboard layout switching.

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

All files are self-contained in this repo:

```
/Users/shayshimonov/Projects/my/fn-toggle/
├── fn-toggle.sh                # Main bash script ⭐
├── toggle_helper.applescript   # AppleScript for UI automation ⭐
├── switch_keyboard.swift       # Keyboard layout switcher (TIS-based) ⭐
└── README.md                   # Documentation
```

**How they work together:**
1. `fn-toggle.sh` - Entry point, calls the Swift helper then AppleScript
2. `switch_keyboard.swift` - Uses Carbon/TIS to switch to English keyboard
3. `toggle_helper.applescript` - Opens System Settings and toggles Function Keys

All three files must be in the same directory.
