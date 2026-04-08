#!/data/data/com.termux/files/usr/bin/bash

# === Android Ghost Storage Hunter v5.0 ===
# Rebuilt for maximum safety and accurate directory scanning

# Define text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Ensure hidden files are caught in globbing
shopt -s dotglob

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${PURPLE}       Android Ghost Storage Hunter v5.0          ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 1. Permission Check
echo -e "${BLUE}[*] Checking storage permissions...${NC}"
if [ ! -d "/sdcard/Android" ]; then
    echo -e "${YELLOW}[!] Storage access not detected.${NC}"
    echo -e "${GREEN}[>] Attempting to request permission...${NC}"
    termux-setup-storage
    echo -e "${RED}[!] Please GRANT permission in the popup and RE-RUN the script.${NC}"
    exit 1
fi
echo -e "${GREEN}[✓] Storage access confirmed.${NC}"

# 2. Scanning Setup
SCAN_PATH="/sdcard"
TEMP_FILE="${TMPDIR:-/data/data/com.termux/files/usr/tmp}/ghost_hunt_v5"

echo -e "\n${BLUE}[*] Scanning contents of: ${WHITE}${SCAN_PATH}${NC}"
echo -e "${YELLOW}[!] Note: ${NC}Analyzing top-level folders and files (including hidden ones)."

# Spinner function for UX
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# 3. Accurate Scanning
echo -ne "\n${CYAN}[*] Hunting for the top 20 offenders... ${NC}"

# Scan exactly one level deep, including files and hidden items
(du -sh "$SCAN_PATH"/* 2>/dev/null | sort -hr | head -n 20 > "$TEMP_FILE") &
spinner $!

echo -e "${GREEN}DONE!${NC}"

# 4. Display Results
echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━ TOP 20 OFFENDERS ━━━━━━━━━━━━━━━━━━━━${NC}"
printf "${BLUE}%-10s %-s${NC}\n" "SIZE" "PATH"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ ! -s "$TEMP_FILE" ]; then
    echo -e "${RED}[!] No items found. Check your storage permissions.${NC}"
else
    while read -r line; do
        SIZE=$(echo "$line" | awk '{print $1}')
        PATH_NAME=$(echo "$line" | cut -f2-)
        
        # Color code based on size
        if [[ "$SIZE" == *G* ]]; then
            SIZE_COLOR=$RED
        elif [[ "$SIZE" == *M* ]]; then
            SIZE_COLOR=$YELLOW
        else
            SIZE_COLOR=$GREEN
        fi

        printf "${SIZE_COLOR}%-10s${NC} %s\n" "$SIZE" "$PATH_NAME"
    done < "$TEMP_FILE"
fi

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 5. Strictly Manual Investigation & Deletion
while true; do
    echo -e "\n${YELLOW}[?] Enter the EXACT path to investigate (or type 'exit' to quit):${NC}"
    read -r TARGET_PATH < /dev/tty

    if [[ "$TARGET_PATH" == "exit" ]]; then
        break
    fi

    if [[ ! -e "$TARGET_PATH" ]]; then
        echo -e "${RED}[!] Error: Path does not exist. Copy it exactly from the list above.${NC}"
        continue
    fi

    # Preview
    echo -e "\n${BLUE}━━━━━━━━━━━━ Investigating: $(basename "$TARGET_PATH") ━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}[*] Current Size:${NC} $(du -sh "$TARGET_PATH" | awk '{print $1}')"
    echo -e "${CYAN}[*] Content Preview:${NC}"
    if [[ -d "$TARGET_PATH" ]]; then
        ls -Fh "$TARGET_PATH" | head -n 15
        echo -e "${BLUE}(Showing first 15 items...)${NC}"
    else
        echo -e "${GREEN}This is a single file.${NC}"
    fi
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Final Warning
    echo -ne "${RED}[WARNING] Are you sure you want to completely delete this item and all its contents? (y/n): ${NC}"
    read -r confirm < /dev/tty

    if [[ "$confirm" == "y" ]]; then
        echo -e "${YELLOW}[*] Deleting...${NC}"
        if rm -rfv "$TARGET_PATH"; then
            echo -e "${GREEN}[✓] Successfully deleted.${NC}"
        else
            echo -e "${RED}[!] Failed to delete. Item might be system-protected.${NC}"
        fi
    else
        echo -e "${CYAN}[-] Deletion cancelled. Nothing was touched.${NC}"
    fi
done

echo -e "\n${GREEN}Thank you for using Ghost Storage Hunter! Cleanup complete.${NC}"
rm "$TEMP_FILE" 2>/dev/null
