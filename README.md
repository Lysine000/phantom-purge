# Phantom Purge

A powerful Termux tool to find and remove massive "Other" storage bloat. Optimized for Realme UI, ColorOS, and MT Manager users.

---

## Quick Start (Installation)

Paste this single command into Termux to run the tool instantly:

`command -v curl >/dev/null || pkg install curl -y && curl -sL https://raw.githubusercontent.com/Lysine000/phantom-purge/main/bloat-hunter.sh | bash`

---

## How to Use (Controls)

When the script finds a file or folder larger than 1GB, it will ask for your permission to delete it. Use the following keys:

* **Type 'y' or 'yes'**: To permanently delete the item and free up space.
* **Type 'n' or any other key**: To safely skip the item and move to the next one.
* **Critical Folders**: If the script detects a system or media folder (like Android, DCIM, or Pictures), it will throw a red `[WARNING]` first and require you to type the full word **'yes'** to confirm deletion.

---

## ⚠️ Warning: Permanent Deletion

**All deletions are PERMANENT.** This tool is for advanced users. Any data loss (Photos, Apps, or Files) cannot be recovered. Always verify the folder path before confirming a deletion. Use at your own risk.

---

## Features (v3.1)

* **Smart Installation:** Skips the curl installation process if it is already present.
* **Interactive Hunt:** Prompts for the specific GB amount you are hunting.
* **Folder Detection:** Now finds massive directories (like MT Manager's `.recycle`) in addition to files.
* **Safety Gates:** Requires double-confirmation for critical system and photo directories (DCIM, Android, Pictures).
* **Hidden Scan:** Finds hidden directories starting with a dot (`.`) that standard system cleaners miss.

---

## Why is my storage full?

On Android 14/15/16, the "Other" storage category balloons because:
* **MT Manager:** Moves deleted files to a hidden `/sdcard/MT2/.recycle/` folder.
* **Media Caches:** WhatsApp/Telegram Sent folders duplicate every video you share.
* **Thumbnails:** Corrupted system files in the DCIM directory.

---

## Post-Cleaning Steps

If your system storage settings still show a high number after cleaning:
1. **Restart your phone:** This forces the system to update its disk index.
2. **Clear Media Storage:** Go to Settings > Apps > Show System > Media Storage > Clear Data.
3. **Wait:** Give the OS about 10 minutes to recalculate the actual storage used.

---

## License
Licensed under the MIT License. See the LICENSE file for details.