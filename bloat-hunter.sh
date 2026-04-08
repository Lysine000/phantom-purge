#!/data/data/com.termux/files/usr/bin/bash

# === Android Ghost Storage Hunter v4.0 ===
# Optimized for finding hidden cache and large directories

# Define text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${PURPLE}       Android Ghost Storage Hunter v4.0          ${NC}"
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
echo -e "\n${BLUE}[*] Preparing to scan: ${WHITE}${SCAN_PATH}${NC}"
echo -e "${YELLOW}[!] Note: ${NC}Scanning excludes 'Android/data' (requires root)."
echo -e "${YELLOW}[!] Note: ${NC}This may take a minute depending on your storage size."

# 3. Execution
echo -ne "\n${CYAN}[*] Hunting for the top 20 offenders... ${NC}"

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

# Run du in background and show spinner
# --exclude excludes the Android folder which is usually inaccessible on newer Android versions
TEMP_FILE=$(mktemp)
(du -ah "$SCAN_PATH" --exclude="$SCAN_PATH/Android" 2>/dev/null | sort -hr | head -n 20 > "$TEMP_FILE") &
spinner $!

echo -e "${GREEN}DONE!${NC}"

# 4. Display Results
echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━ TOP 20 OFFENDERS ━━━━━━━━━━━━━━━━━━━━${NC}"
printf "${BLUE}%-10s %-s${NC}\n" "SIZE" "PATH"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ ! -s "$TEMP_FILE" ]; then
    echo -e "${RED}[!] No large items found. Your storage might be genuinely clean!${NC}"
else
    # Read the results and format them
    while read -r line; do
        SIZE=$(echo "$line" | awk '{print $1}')
        PATH_NAME=$(echo "$line" | cut -f2-)
        
        # Color code based on size
        if [[ "$SIZE" == *G* ]]; then
            SIZE_COLOR=$RED
        elif [[ "$SIZE" == *M* ]]; then
            # Only highlight if > 500M
            NUM=$(echo "$SIZE" | sed 's/M//')
            if (( $(echo "$NUM > 500" | bc -l 2>/dev/null || echo 0) )); then
                SIZE_COLOR=$YELLOW
            else
                SIZE_COLOR=$GREEN
            fi
        else
            SIZE_COLOR=$GREEN
        fi

        printf "${SIZE_COLOR}%-10s${NC} %s\n" "$SIZE" "$PATH_NAME"
    done < "$TEMP_FILE"
fi

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 5. Interactive Deletion
echo -e "\n${YELLOW}[?] Would you like to enter deletion mode? (y/n): ${NC}"
read -r enter_delete < /dev/tty

if [[ "$enter_delete" =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}[*] Entering Deletion Mode. Be CAREFUL!${NC}"
    
    while read -r line; do
        SIZE=$(echo "$line" | awk '{print $1}')
        PATH_NAME=$(echo "$line" | cut -f2-)

        # Skip the root /sdcard path itself
        if [[ "$PATH_NAME" == "$SCAN_PATH" ]]; then continue; fi

        echo -e "\n--------------------------------------------------"
        echo -e "ITEM: ${RED}$PATH_NAME${NC}"
        echo -e "SIZE: ${GREEN}$SIZE${NC}"
        
        # Safety Gate
        is_critical=false
        if [[ "$PATH_NAME" =~ "/DCIM" ]] || [[ "$PATH_NAME" =~ "/Pictures" ]] || [[ "$PATH_NAME" =~ "/Download" ]]; then
            is_critical=true
            echo -e "${YELLOW}[!] WARNING: This is a standard media/download folder.${NC}"
        fi

        echo -ne "${PURPLE}[?] Delete this item? (y/n/skip all): ${NC}"
        read -r choice < /dev/tty

        if [[ "$choice" == "y" ]]; then
            if rm -rfv "$PATH_NAME"; then
                echo -e "${GREEN}[✓] Deleted successfully.${NC}"
            else
                echo -e "${RED}[!] Failed to delete. (System protected?)${NC}"
            fi
        elif [[ "$choice" == "skip" ]]; then
            break
        else
            echo -e "${CYAN}[-] Skipped.${NC}"
        fi
    done < "$TEMP_FILE"
fi

echo -e "\n${GREEN}Thank you for using Ghost Storage Hunter!${NC}"
rm "$TEMP_FILE" 2>/dev/null
