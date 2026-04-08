# Phantom Purge

A powerful Termux tool to find and remove massive "Other" storage bloat. Optimized for Realme UI, ColorOS, and MT Manager users.

---

## Quick Start (Installation)

Paste this single command into Termux to run the tool instantly:

`command -v curl >/dev/null || pkg install curl -y && curl -sL https://raw.githubusercontent.com/Lysine000/phantom-purge/main/bloat-hunter.sh | bash`

---

## How to Use (Controls)

The script scans for the top 20 largest folders and files on your storage. Once the scan is complete, you can enter **Deletion Mode** to review each item.

* **Type 'y'**: To permanently delete the item and free up space.
* **Type 'n'**: To safely skip the item and move to the next one.
* **Type 'skip'**: To exit deletion mode and finish.

---

## ⚠️ Warning: Permanent Deletion

**All deletions are PERMANENT.** This tool is for advanced users. Any data loss (Photos, Apps, or Files) cannot be recovered. Always verify the folder path before confirming a deletion. Use at your own risk.

---

## Features (v4.0)

* **Permission Check:** Automatically detects and requests Termux storage permissions.
* **Deep Directory Scan:** Uses `du` (disk usage) to find massive folders filled with thousands of tiny cache files, not just single large files.
* **Top 20 Offenders:** Outputs a clean, sorted list of the biggest storage hogs so you can see exactly where your space went.
* **Smart UI:** Color-coded results (Red for GBs, Yellow for large MBs) with a live progress spinner.
* **Safety Gates:** Warns you if a folder is a standard media directory (DCIM, Pictures, Download).

---

## Why is my storage full?

On modern Android versions, the "Other" storage category balloons because of:
* **MT Manager:** Moves deleted files to hidden recycle bins like `/sdcard/MT2/.recycle/`.
* **Social Media Cache:** Telegram, WhatsApp, and Discord cache thousands of small media files.
* **App Thumbnails:** Corrupted or massive thumbnail databases in the DCIM directory.

---

## Post-Cleaning Steps

If your system storage settings still show a high number after cleaning:
1. **Restart your phone:** Forces the OS to re-index the disk.
2. **Clear Media Storage:** Settings > Apps > Show System > Media Storage > Clear Data.
3. **Wait:** It can take 5-10 minutes for Android to recalculate storage after a big wipe.

---

## License
Licensed under the MIT License. See the LICENSE file for details.
