#!/data/data/com.termux/files/usr/bin/bash

# Define text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}=== Android Ghost Storage Hunter v1.9 ===${NC}"

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

echo -e "${YELLOW}[*] Scanning for folders/files larger than 1GB...${NC}" 
echo -e "${YELLOW}[*] This may take a minute. Please wait...${NC}\n"

# Define critical paths pattern (faster matching)
CRITICAL_PATTERN="/(Android|DCIM|Pictures)/"

# 2. Function for Manual Deletion with Safety Checks
manual_delete() {
    local path="$1"
    local size="$2"
    
    echo -e "--------------------------------------------------"
    echo -e "FOUND: ${RED}$path${NC}"
    echo -e "SIZE:  ${GREEN}$size${NC}"
    
    # Safety Check for critical folders (optimized matching)
    if [[ "$path" =~ (Android|DCIM|Pictures) ]]; then
        echo -e "${RED}[WARNING] This is a critical system/media folder.${NC}"
        echo -ne "${YELLOW}[?] Type 'yes' to DELETE or 'n' to SKIP: ${NC}"
        read confirm < /dev/tty
        
        if [[ "$confirm" == "yes" ]]; then
             rm -rf "$path" 2>/dev/null && echo -e "${GREEN}[OK] Deleted.${NC}" || echo -e "${RED}[!] Error: Permission Denied.${NC}"
        else
            echo -e "${CYAN}[-] Skipped critical folder.${NC}"
        fi
        return 
    fi

    # Deletion Prompt for non-critical items (hidden folders, logs, etc.)
echo -ne "${YELLOW}[?] Type 'yes' to DELETE or 'n' to SKIP: ${NC}"
read choice < /dev/tty
    
    if [[ "$choice" == "yes" ]] || [[ "$choice" == "y" ]]; then
        rm -rf "$path" 2>/dev/null && echo -e "${GREEN}[OK] Deleted.${NC}" || echo -e "${RED}[!] Error: Permission Denied.${NC}"
    else
        echo -e "${CYAN}[-] Skipped.${NC}"
    fi
}

# 3. Deep Scan Logic (Optimized - Single pass, no intermediate grep)
IFS=$'\n'
# OPTIMIZATION: Combine du, grep, sort, and awk into single pipeline
# Filter for G (gigabytes) and parse in one pass
LARGE_ITEMS=$(du -sh /sdcard/* /sdcard/.[!.]* 2>/dev/null | awk '$1 ~ /[0-9]+(\.[0-9]+)?G/ {print}' | sort -hr)

if [[ -z "$LARGE_ITEMS" ]]; then
    echo -e "${RED}[!] No folders/files larger than 1GB detected.${NC}"
else
    COUNT=0
    TOTAL=$(echo "$LARGE_ITEMS" | wc -l)
    for item in $LARGE_ITEMS; do
        # OPTIMIZATION: Single awk pass to extract both size and path
        read SIZE PATH_NAME < <(echo "$item" | awk '{print $1, $2}')
        COUNT=$((COUNT + 1))
        echo -e "${CYAN}[*] Processing [$COUNT/$TOTAL]${NC}"
        manual_delete "$PATH_NAME" "$SIZE"
    done
fi

echo -e "\n${GREEN}Scan complete. If storage is still full, REBOOT your phone.${NC}"