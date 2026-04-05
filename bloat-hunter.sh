#!/data/data/com.termux/files/usr/bin/bash

# Define text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}=== Android Ghost Storage Hunter v3.1 ===${NC}"

# Check for storage permission
if [ ! -d "/sdcard/Android" ]; then
    echo -e "${RED}[!] Storage permission not detected. Requesting now...${NC}"
    termux-setup-storage
    exit 1
fi

echo -ne "${YELLOW}[?] Approx how many GB are you hunting? (e.g. 1): ${NC}"
read GHOST_SIZE < /dev/tty

# Validate GHOST_SIZE is a number
if [[ ! "$GHOST_SIZE" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}[!] Invalid input. Defaulting to 1GB.${NC}"
    GHOST_SIZE=1
fi

manual_delete() {
    local path="$1"
    local size="$2"
    local is_critical=false

    # Safety Gates: Check for critical folders (DCIM, Android, etc.)
    if [[ "$path" =~ "/sdcard/Android" ]] || [[ "$path" =~ "/sdcard/DCIM" ]] || [[ "$path" =~ "/sdcard/Pictures" ]]; then
        is_critical=true
    fi
    
    echo -e "--------------------------------------------------"
    if [ "$is_critical" = true ]; then
        echo -e "${RED}[WARNING] CRITICAL SYSTEM/MEDIA PATH DETECTED!${NC}"
    fi
    echo -e "FOUND: ${RED}$path${NC}"
    echo -e "SIZE:  ${GREEN}$size${NC}"
    
    if [ "$is_critical" = true ]; then
        echo -ne "${YELLOW}[?] Type exactly 'yes' to DELETE or 'n' to SKIP: ${NC}"
    else
        echo -ne "${YELLOW}[?] Type 'yes' (or 'y') to DELETE or 'n' to SKIP: ${NC}"
    fi
    
    read choice < /dev/tty
    
    local confirmed=false
    if [ "$is_critical" = true ]; then
        if [[ "$choice" == "yes" ]]; then confirmed=true; fi
    else
        if [[ "$choice" == "yes" ]] || [[ "$choice" == "y" ]]; then confirmed=true; fi
    fi

    if [ "$confirmed" = true ]; then
        echo -e "${CYAN}[DEBUG] Attempting raw system delete...${NC}"
        
        # -rf handles both files and directories
        if rm -rfv "$path"; then
            echo -e "${GREEN}[OK] Termux successfully wiped it.${NC}"
        else
            echo -e "${RED}[FATAL] Termux failed to delete the item. See error above.${NC}"
        fi
    else
        echo -e "${CYAN}[-] Skipped.${NC}"
    fi
}

echo -e "${YELLOW}[*] Searching for items larger than ${GHOST_SIZE}GB...${NC}" 

# 1. Find large files
FILES=$(find /sdcard/ -type f -size "+${GHOST_SIZE}G" -exec du -h {} + 2>/dev/null)

# 2. Find large directories (including hidden ones)
DIRS=$(du -sh /sdcard/*/ /sdcard/.*/ 2>/dev/null | awk -v size="$GHOST_SIZE" '$1 ~ /G/ { 
    val = substr($1, 1, length($1)-1); 
    if (val >= size) print $0 
}')

# Combine and sort results
LARGE_ITEMS=$(echo -e "$FILES\n$DIRS" | sed '/^$/d' | sort -hr)

if [[ -z "$LARGE_ITEMS" ]]; then
    echo -e "${RED}[!] No items larger than ${GHOST_SIZE}GB detected.${NC}"
else
    COUNT=0
    TOTAL=$(echo "$LARGE_ITEMS" | wc -l)
    
    while IFS= read -r item; do
        # Split size and path, handling paths with spaces
        SIZE=$(echo "$item" | awk '{print $1}')
        PATH_NAME=$(echo "$item" | cut -f2-)
        
        # Safety: Prevent accidental root/sdcard deletion
        if [[ "$PATH_NAME" == "/sdcard/" ]] || [[ -z "$PATH_NAME" ]]; then continue; fi

        COUNT=$((COUNT + 1))
        echo -e "${CYAN}[*] Processing [$COUNT/$TOTAL]${NC}"
        manual_delete "$PATH_NAME" "$SIZE"
    done <<< "$LARGE_ITEMS"
fi
