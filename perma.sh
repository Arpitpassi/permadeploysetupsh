#!/bin/bash

echo "Installing Nitya wallet setup tool..."
# No local directory creation needed since config is stored on server

# Create the setup.sh script in a temporary location for execution
TEMP_DIR=$(mktemp -d)
cat > "$TEMP_DIR/setup.sh" << 'EOL'
#!/bin/bash

# Nitya Wallet Setup Script

# ANSI colors for terminal styling
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
WHITE="\033[1;37m"
RESET="\033[0m"

# Simple title display
function print_title() {
  echo -e "${MAGENTA}
    ███╗   ██╗██╗████████╗██╗   ██╗ █████╗ 
    ████╗  ██║██║╚══██╔══╝╚██╗ ██╔╝██╔══██╗
    ██╔██╗ ██║██║   ██║    ╚████╔╝ ███████║
    ██║╚██╗██║██║   ██║     ╚██╔╝  ██╔══██║
    ██║ ╚████║██║   ██║      ██║   ██║  ██║
    ╚═╝  ╚═══╝╚═╝   ╚═╝      ╚═╝   ╚═╝  ╚═╝
                                                                      
    ${WHITE}> Permanently deploy your web apps to the decentralized Arweave network${RESET}
    ${CYAN}    
    ┌────┐        ┌────┐
    │${BLUE}████${CYAN}│━━━━━━━━│${BLUE}████${CYAN}│     ${WHITE}PERMANENT DEPLOYMENT${CYAN}
    └────┘╲      ╱└────┘     ${WHITE}DECENTRALIZED${CYAN}
           ╲    ╱
            ╲  ╱
           ┌────┐
           │${BLUE}████${CYAN}│
           └────┘
         ${RESET}
"
}

# Function to setup pool type
function setup_pool_type() {
  echo -e "${BLUE}╔════ POOL CONFIGURATION ════╗${RESET}"
  echo -e "${CYAN}Please select your pool type:${RESET}"
  echo -e "${WHITE}1. Community pool deployment${RESET}"
  echo -e "${WHITE}2. Event pool deployment${RESET}"
  read -p "Enter your choice (1 or 2): " POOL_TYPE_CHOICE

  if [ "$POOL_TYPE_CHOICE" = "1" ]; then
    POOL_TYPE="community"
    echo -e "${GREEN}✓ Community pool selected${RESET}"
  elif [ "$POOL_TYPE_CHOICE" = "2" ]; then
    POOL_TYPE="event"
    echo -e "${GREEN}✓ Event pool selected${RESET}"
    
    # For event pools, get the name and password
    read -p "Enter a name for your event pool: " EVENT_POOL_NAME
    read -s -p "Enter a password for your event pool: " EVENT_POOL_PASSWORD
    echo
    
    # Ask for max allowed users for this event pool
    read -p "Enter maximum number of allowed users for this event: " MAX_USERS
    
    echo -e "${GREEN}✓ Event pool '${EVENT_POOL_NAME}' configured with ${MAX_USERS} maximum users${RESET}"
  else
    echo -e "${RED}Invalid choice. Defaulting to community pool...${RESET}"
    POOL_TYPE="community"
  fi
}

# Visual progress bar
function progress_bar() {
  local percent=$1
  local width=${2:-30}
  local filled=$((width * percent / 100))
  local empty=$((width - filled))
  local bar="${GREEN}["
  for ((i=0; i<filled; i++)); do bar+="█"; done
  bar+="${RED}"
  for ((i=0; i<empty; i++)); do bar+=" "; done
  bar+="] ${percent}%${RESET}"
  
  echo -ne "\r${bar}"
  if [ $percent -eq 100 ]; then echo; fi
}

# Copy wallet address to clipboard
function copy_to_clipboard() {
  local text=$1
  
  echo -e "\n${WHITE}${text}${RESET}"
  echo -e "${YELLOW}Press 'c' to copy wallet address to clipboard, any other key to continue...${RESET}"
  
  read -n 1 -s key
  if [[ $key == "c" || $key == "C" ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then # macOS
      echo -n "$text" | pbcopy
      echo -e "${GREEN}\nWallet address copied to clipboard!${RESET}"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then # Windows
      echo -n "$text" | clip
      echo -e "${GREEN}\nWallet address copied to clipboard!${RESET}"
    else # Linux and others
      if command -v xsel &> /dev/null; then
        echo -n "$text" | xsel -ib
        echo -e "${GREEN}\nWallet address copied to clipboard!${RESET}"
      elif command -v xclip &> /dev/null; then
        echo -n "$text" | xclip -selection clipboard
        echo -e "${GREEN}\nWallet address copied to clipboard!${RESET}"
      elif command -v wl-copy &> /dev/null; then
        echo -n "$text" | wl-copy
        echo -e "${GREEN}\nWallet address copied to clipboard!${RESET}"
      else
        echo -e "${RED}Couldn't copy automatically. Please copy manually:${RESET}"
        echo -e "${YELLOW}${text}${RESET}"
      fi
    fi
  fi
}

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${RED}Error: Node.js is required. Please install it:${RESET}"
    echo "  - Linux: sudo apt install nodejs"
    echo "  - macOS: brew install node"
    echo "  - Windows: download from https://nodejs.org/"
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo -e "${RED}Error: npm is required. It usually comes with Node.js.${RESET}"
    exit 1
fi

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo -e "${RED}Error: curl is required. Please install it:${RESET}"
    echo "  - Linux: sudo apt install curl"
    echo "  - macOS: brew install curl"
    echo "  - Windows: download from https://curl.se/download.html"
    exit 1
fi

# Check if sponsor server is running
SERVER_URL="${NITYA_SERVER_URL:-http://localhost:3000}"
SERVER_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$SERVER_URL" 2>/dev/null || echo "000")
if [ "$SERVER_STATUS" = "000" ]; then
    echo -e "${RED}Error: Sponsor server is not running at $SERVER_URL${RESET}"
    echo -e "${YELLOW}Please start the sponsor server and try again.${RESET}"
    exit 1
else
    echo -e "${GREEN}✓ Connected to sponsor server at $SERVER_URL${RESET}"
fi

# Install arweave package if needed
echo -e "${BLUE}Checking for required packages...${RESET}"
if ! npm list -g arweave &> /dev/null; then
    echo -e "${YELLOW}Installing arweave package...${RESET}"
    npm install -g arweave
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to install arweave package. Try running 'npm install -g arweave' manually.${RESET}"
        exit 1
    fi
    echo -e "${GREEN}Arweave package installed successfully.${RESET}"
else
    echo -e "${GREEN}Arweave package already installed.${RESET}"
fi

# Function to generate a new Arweave wallet
generate_wallet() {
    echo -e "${BLUE}Generating a new Arweave wallet...${RESET}"
    WALLET_FILE=$(mktemp)
    
    # Show progress bar while generating wallet
    for i in {0..100..10}; do
        progress_bar $i
        sleep 0.1
    done
    
    # Generate the wallet
    node -e "
        const Arweave = require('arweave');
        const fs = require('fs');
        Arweave.init().wallets.generate().then(key => {
            fs.writeFileSync('$WALLET_FILE', JSON.stringify(key, null, 2));
            console.log('Wallet generated successfully');
        }).catch(err => console.error(err));
    " > /dev/null 2>&1
    
    if [ ! -f "$WALLET_FILE" ]; then
        echo -e "\n${RED}Error: Failed to generate wallet.${RESET}"
        exit 1
    fi
    
    echo -e "\n${GREEN}✓ New wallet generated${RESET}"
    return 0
}

# Function to get wallet address from keyfile
get_wallet_address() {
    local wallet_file="$1"
    echo -e "${BLUE}Getting wallet address...${RESET}" >&2
    
    WALLET_ADDRESS=$(node -e "
        const fs = require('fs');
        const Arweave = require('arweave');
        Arweave.init().wallets.jwkToAddress(JSON.parse(fs.readFileSync('$wallet_file')))
            .then(addr => console.log(addr))
            .catch(err => console.error(err));
    " 2>/dev/null)
    
    if [ -z "$WALLET_ADDRESS" ]; then
        echo -e "${RED}Error: Could not derive wallet address from $wallet_file.${RESET}"
        exit 1
    fi
    
    echo "$WALLET_ADDRESS"
}

# Function to configure pool and upload wallet to server
configure_pool() {
    local wallet_file="$1"
    local wallet_address="$2"
    
    echo -e "\n${BLUE}╔════ CONFIGURING POOL ON SERVER ════╗${RESET}"
    echo -e "${CYAN}Sending pool configuration and wallet to sponsor server...${RESET}"
    
    API_KEY="sponsor-api-key-456"
    CONFIG_URL="$SERVER_URL/configure-pool"
    
    # Prepare curl command with form data
    CURL_ARGS=(
        -X POST
        -H "X-API-Key: $API_KEY"
        -F "wallet=@$wallet_file"
        -F "poolType=$POOL_TYPE"
    )
    
    if [ "$POOL_TYPE" = "event" ]; then
        CURL_ARGS+=(
            -F "eventPoolName=$EVENT_POOL_NAME"
            -F "eventPoolPassword=$EVENT_POOL_PASSWORD"
            -F "maxUsers=$MAX_USERS"
        )
    fi
    
    # Show progress bar
    for i in {0..95..5}; do
        progress_bar $i
        sleep 0.1
    done
    
    RESPONSE=$(curl -s -o "$TEMP_DIR/response.json" -w "%{http_code}" "${CURL_ARGS[@]}" "$CONFIG_URL" 2>/dev/null)
    
    progress_bar 100
    
    if [ "$RESPONSE" != "200" ]; then
        echo -e "${RED}Error: Failed to configure pool on server. HTTP status: $RESPONSE${RESET}"
        if [ -f "$TEMP_DIR/response.json" ]; then
            cat "$TEMP_DIR/response.json"
            rm -f "$TEMP_DIR/response.json"
        fi
        exit 1
    fi
    
    UPLOADED_ADDRESS=$(node -e "
        const fs = require('fs');
        try {
            const response = JSON.parse(fs.readFileSync('$TEMP_DIR/response.json'));
            console.log(response.walletAddress || '');
        } catch (e) {
            console.error('Failed to parse response');
        }
    " 2>/dev/null)
    
    rm -f "$TEMP_DIR/response.json"
    
    if [ -z "$UPLOADED_ADDRESS" ]; then
        echo -e "${RED}Error: Could not retrieve wallet address from server response.${RESET}"
        exit 1
    fi
    
    if [ "$UPLOADED_ADDRESS" != "$wallet_address" ]; then
        echo -e "${RED}Error: Uploaded wallet address mismatch. Expected: $wallet_address, Got: $UPLOADED_ADDRESS${RESET}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Pool configured and wallet uploaded successfully. Address: ${RESET}$UPLOADED_ADDRESS"
    
    copy_to_clipboard "$UPLOADED_ADDRESS"
    return 0
}

print_title

echo -e "${BLUE}╔════ POOL SETUP ════╗${RESET}"
echo -e "${CYAN}Configuring pool on server: ${RESET}$SERVER_URL"

# Configure the pool type
setup_pool_type

# Ask user whether to generate a new wallet or use an existing one
echo -e "\n${BLUE}╔════ WALLET SELECTION ════╗${RESET}"
echo -e "${CYAN}Do you want to generate a new sponsor wallet or use an existing one?${RESET}"
echo -e "${WHITE}1. Generate a new wallet${RESET}"
echo -e "${WHITE}2. Use an existing wallet${RESET}"
read -p "Enter your choice (1 or 2): " CHOICE

if [ "$CHOICE" = "1" ]; then
    generate_wallet
    WALLET_FILE="$WALLET_FILE"
elif [ "$CHOICE" = "2" ]; then
    read -p "Enter the path to your existing wallet keyfile (e.g., /path/to/wallet.json): " EXISTING_WALLET
    if [ ! -f "$EXISTING_WALLET" ]; then
        echo -e "${RED}Error: Wallet keyfile not found at $EXISTING_WALLET${RESET}"
        exit 1
    fi
    WALLET_FILE="$EXISTING_WALLET"
    echo -e "${GREEN}✓ Using existing wallet at ${RESET}$EXISTING_WALLET"
else
    echo -e "${RED}Invalid choice. Exiting...${RESET}"
    exit 1
fi

# Verify wallet file exists
if [ ! -f "$WALLET_FILE" ]; then
    echo -e "${RED}Error: Wallet file not found at $WALLET_FILE${RESET}"
    exit 1
fi

# Get and display the wallet address
echo -e "\n${BLUE}╔════ WALLET ADDRESS ════╗${RESET}"
WALLET_ADDRESS=$(get_wallet_address "$WALLET_FILE")
echo -e "${GREEN}✓ Sponsor wallet address: ${RESET}"
copy_to_clipboard "$WALLET_ADDRESS"

# Configure pool and upload wallet to server
configure_pool "$WALLET_FILE" "$WALLET_ADDRESS"

# Clean up temporary wallet file if generated
if [ "$CHOICE" = "1" ]; then
    rm -f "$WALLET_FILE"
fi

echo -e "\n${BLUE}╔════ NEXT STEPS ════╗${RESET}"
echo -e "${YELLOW}Please fund this wallet with AR or Turbo credits at https://ardrive.io/turbo${RESET}"
echo -e "${GREEN}Nitya Pool Setup completed successfully!${RESET}"
EOL

# Make the setup script executable
chmod +x "$TEMP_DIR/setup.sh"

# Run the setup script
"$TEMP_DIR/setup.sh"

# Clean up temporary directory
rm -rf "$TEMP_DIR"

echo "Installation complete! Pool configuration is stored on the server."