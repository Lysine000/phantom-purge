#!/data/data/com.termux/files/usr/bin/bash

# Define text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}=== Android Ghost Storage Hunter v2.0 (Fixed) ===${NC}"

# --- HIGH VISIBILITY WARNING ---
echo -e "${RED}##################################################${NC}"
echo -e "${RED}#                  WARNING                       #${NC}"
echo -e "${RED}##################################################${NC}"
echo -e "${YELLOW}* All deletions performed by this tool are PERMANENT.${NC}"
echo -e "${YELLOW}* Deleted data CANNOT be recovered.${NC}"
echo -e "${YELLOW}* Any data loss is your responsibility. Use with care.${NC}"
echo -e "${RED}##################################################${NC}"
echo -e ""

# Check for storage permission
if [ ! -d "/sdcard/Android" ]; then
    echo -e "${RED}[!] Storage permission not detected. Requesting now...${NC}"
    termux-setup-storage
    echo -e "${CYAN}[*] Please grant permission on your device and run the script again.${NC}"
    exit 1
fi

# 1. User Input
echo -ne "${YELLOW}[?] Approx how many GB are you hunting? (e.g. 60): ${NC}"
read GHOST_SIZE < /dev/tty

echo -e "${YELLOW}[*] Searching for individual FILES larger than 1GB...${NC}" 
echo -e "${YELLOW}[*] This may take a minute. Please wait...${NC}\n"

# 2. Function for Manual Deletion with Safety Checks
manual_delete() {
    local path="$1"
    local size="$2"
    
    echo -e "--------------------------------------------------"
    echo -e "FOUND: ${RED}$path${NC}"
    echo -e "SIZE:  ${GREEN}$size${NC}"
    
    # Safety Check for critical folders
    if [[ "$path" =~ (Android|DCIM|Pictures) ]]; then
        echo -e "${RED}[WARNING] This file is inside a critical system/media folder.${NC}"
        echo -ne "${YELLOW}[?] Type 'yes' to DELETE or 'n' to SKIP: ${NC}"
        read confirm < /dev/tty
        
        if [[ "$confirm" == "yes" ]]; then
             # Using rm -f because we are exclusively targeting files now
             rm -f "$path" 2>/dev/null && echo -e "${GREEN}[OK] Deleted.${NC}" || echo -e "${RED}[!] Error: Permission Denied.${NC}"
        else
            echo -e "${CYAN}[-] Skipped critical file.${NC}"
        fi
        return 
    fi

    # Deletion Prompt for non-critical items
    echo -ne "${YELLOW}[?] Type 'yes' to DELETE or 'n' to SKIP: ${NC}"
    read choice < /dev/tty
    
    if [[ "$choice" == "yes" ]] || [[ "$choice" == "y" ]]; then
        rm -f "$path" 2>/dev/null && echo -e "${GREEN}[OK] Deleted.${NC}" || echo -e "${RED}[!] Error: Permission Denied.${NC}"
    else
        echo -e "${CYAN}[-] Skipped.${NC}"
    fi
}

# 3. Deep Scan Logic (True File Hunter)
# We now use 'find' to target actual files (+1G) instead of relying on 'du'
LARGE_ITEMS=$(find /sdcard/ -type f -size +1G -exec du -h {} + 2>/dev/null | sort -hr)

if [[ -z "$LARGE_ITEMS" ]]; then
    echo -e "${RED}[!] No files larger than 1GB detected.${NC}"
else
    COUNT=0
    TOTAL=$(echo "$LARGE_ITEMS" | wc -l)
    
    # Using a while loop prevents IFS issues from breaking the file paths during deletion
    while IFS= read -r item; do
        # read automatically splits the size (first word) from the path (the rest of the string)
        read -r SIZE PATH_NAME <<< "$item"
        
        COUNT=$((COUNT + 1))
        echo -e "${CYAN}[*] Processing [$COUNT/$TOTAL]${NC}"
        manual_delete "$PATH_NAME" "$SIZE"
    done <<< "$LARGE_ITEMS"
fi

echo -e "\n${GREEN}Scan complete. If storage is still full, REBOOT your phone.${NC}"
