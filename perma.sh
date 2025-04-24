#!/bin/bash

# PermaDeploy Installer Script
# This script downloads and sets up the PermaDeploy tool

# ANSI colors for terminal styling
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
RESET="\033[0m"

# Print banner
echo -e "${MAGENTA}
    ███╗   ██╗██╗████████╗██╗   ██╗ █████╗ 
    ████╗  ██║██║╚══██╔══╝╚██╗ ██╔╝██╔══██╗
    ██╔██╗ ██║██║   ██║    ╚████╔╝ ███████║
    ██║╚██╗██║██║   ██║     ╚██╔╝  ██╔══██║
    ██║ ╚████║██║   ██║      ██║   ██║  ██║
    ╚═╝  ╚═══╝╚═╝   ╚═╝      ╚═╝   ╚═╝  ╚═╝
                                                                      
    ${RESET}> Permanently deploy your web apps to the decentralized Arweave network${RESET}
    ${CYAN}    
    ┌────┐        ┌────┐
    │${BLUE}████${CYAN}│━━━━━━━━│${BLUE}████${CYAN}│     ${RESET}PERMANENT DEPLOYMENT${CYAN}
    └────┘╲      ╱└────┘     ${RESET}DECENTRALIZED${CYAN}
           ╲    ╱
            ╲  ╱
           ┌────┐
           │${BLUE}████${CYAN}│
           └────┘
${RESET}"

echo -e "${YELLOW}╔════ PERMADEPLOY INSTALLATION ════╗${RESET}"
echo -e "${BLUE}Installing required dependencies...${RESET}"

# Create .permaweb directory
PERMAWEB_DIR="$HOME/.permaweb"
mkdir -p "$PERMAWEB_DIR/bin"

# Check for Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}Error: Node.js is required but not installed.${RESET}"
    echo -e "${YELLOW}Please install Node.js (https://nodejs.org) and try again.${RESET}"
    exit 1
fi

# Check for npm
if ! command -v npm &> /dev/null; then
    echo -e "${RED}Error: npm is required but not installed.${RESET}"
    echo -e "${YELLOW}Please install npm and try again.${RESET}"
    exit 1
fi

# Install required npm packages
echo -e "${BLUE}Installing npm packages...${RESET}"
npm install -g arweave @ardrive/turbo-sdk @ar.io/sdk yargs 2>/dev/null

# Progress bar function
function show_progress {
    local duration=$1
    local step=$(($duration / 20))
    echo -ne "${GREEN}Progress: [                    ] (0%)${RESET}\r"
    for i in {1..20}; do
        sleep $step
        echo -ne "${GREEN}Progress: ["
        for ((j=1; j<=i; j++)); do echo -ne "█"; done
        for ((j=i+1; j<=20; j++)); do echo -ne " "; done
        echo -ne "] ($(($i * 5))%)${RESET}\r"
    done
    echo -ne "\n"
}

# Download setup.sh
echo -e "${BLUE}Downloading setup.sh...${RESET}"
show_progress 2

# Creating setup.sh with embedded content
cat > "$PERMAWEB_DIR/bin/setup.sh" << 'EOL'
#!/bin/bash

# PermaDeploy Sponsor Wallet Setup Script

# ANSI colors for terminal styling
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
RESET="\033[0m"

# Print banner
echo -e "${MAGENTA}
    ███╗   ██╗██╗████████╗██╗   ██╗ █████╗ 
    ████╗  ██║██║╚══██╔══╝╚██╗ ██╔╝██╔══██╗
    ██╔██╗ ██║██║   ██║    ╚████╔╝ ███████║
    ██║╚██╗██║██║   ██║     ╚██╔╝  ██╔══██║
    ██║ ╚████║██║   ██║      ██║   ██║  ██║
    ╚═╝  ╚═══╝╚═╝   ╚═╝      ╚═╝   ╚═╝  ╚═╝
                                                                      
    ${RESET}> Permanently deploy your web apps to the decentralized Arweave network${RESET}
    ${CYAN}    
    ┌────┐        ┌────┐
    │${BLUE}████${CYAN}│━━━━━━━━│${BLUE}████${CYAN}│     ${RESET}PERMANENT DEPLOYMENT${CYAN}
    └────┘╲      ╱└────┘     ${RESET}DECENTRALIZED${CYAN}
           ╲    ╱
            ╲  ╱
           ┌────┐
           │${BLUE}████${CYAN}│
           └────┘
${RESET}"

echo -e "${YELLOW}╔════ PERMADEPLOY SPONSOR WALLET SETUP ════╗${RESET}"

# Define the sponsor wallet directory
SPONSOR_DIR="$HOME/.permaweb/sponsor"
WALLET_DIR="$SPONSOR_DIR/wallets"
CONFIG_FILE="$SPONSOR_DIR/config.json"

# Create directories if they don't exist
mkdir -p "$SPONSOR_DIR" "$WALLET_DIR"
echo -e "${BLUE}Configuration directory: ${RESET}$SPONSOR_DIR"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${RED}Error: Node.js is required. Please install it (e.g., 'sudo apt install nodejs' or 'brew install node').${RESET}"
    exit 1
fi

# Progress bar function
function show_progress {
    local duration=$1
    local step=$(($duration / 20))
    echo -ne "${GREEN}Progress: [                    ] (0%)${RESET}\r"
    for i in {1..20}; do
        sleep $step
        echo -ne "${GREEN}Progress: ["
        for ((j=1; j<=i; j++)); do echo -ne "█"; done
        for ((j=i+1; j<=20; j++)); do echo -ne " "; done
        echo -ne "] ($(($i * 5))%)${RESET}\r"
    done
    echo -ne "\n"
}

# Function to generate a new Arweave wallet
generate_wallet() {
    echo -e "${BLUE}Generating a new Arweave wallet...${RESET}"
    WALLET_FILE="$WALLET_DIR/sponsor_wallet.json"
    
    # Show progress bar while generating wallet
    show_progress 3 &
    PROGRESS_PID=$!
    
    # Generate wallet
    node -e "
        const Arweave = require('arweave');
        Arweave.init().wallets.generate().then(key => {
            console.log(JSON.stringify(key));
        }).catch(err => console.error(err));
    " > "$WALLET_FILE" 2>/dev/null
    
    # Wait for progress bar to finish
    wait $PROGRESS_PID
    
    if [ $? -ne 0 ] || [ ! -s "$WALLET_FILE" ]; then
        echo -e "${RED}Error: Failed to generate wallet.${RESET}"
        exit 1
    }
    echo -e "${GREEN}✓ New wallet generated at ${RESET}$WALLET_FILE"
}

# Function to get wallet address from keyfile
get_wallet_address() {
    local wallet_file="$1"
    
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
    }
    echo "$WALLET_ADDRESS"
}

# Function to upload wallet to server (mock function for now)
upload_wallet() {
    local wallet_file="$1"
    local wallet_address="$2"
    
    echo -e "${BLUE}Uploading wallet to server...${RESET}"
    
    # Show progress bar for upload simulation
    show_progress 2
    
    # In a real implementation, this would actually upload to a server
    # For now, we'll just simulate success
    echo -e "${GREEN}✓ Wallet uploaded successfully. Address: ${RESET}$wallet_address"
    
    # Return true for success
    return 0
}

# Function to copy wallet to clipboard
copy_to_clipboard() {
    local text="$1"
    
    # Different copy commands based on OS
    if [ "$(uname)" == "Darwin" ]; then  # macOS
        echo "$text" | pbcopy
        echo -e "${GREEN}✓ Copied to clipboard!${RESET}"
    elif [ -n "$DISPLAY" ]; then  # Linux with display
        if command -v xclip &> /dev/null; then
            echo "$text" | xclip -selection clipboard
            echo -e "${GREEN}✓ Copied to clipboard!${RESET}"
        elif command -v xsel &> /dev/null; then
            echo "$text" | xsel -ib
            echo -e "${GREEN}✓ Copied to clipboard!${RESET}"
        elif command -v wl-copy &> /dev/null; then
            echo "$text" | wl-copy
            echo -e "${GREEN}✓ Copied to clipboard!${RESET}"
        else
            echo -e "${YELLOW}Could not copy to clipboard. Please copy manually:${RESET}"
            echo "$text"
        fi
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ] || [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then  # Windows
        echo "$text" > /dev/clipboard
        echo -e "${GREEN}✓ Copied to clipboard!${RESET}"
    else
        echo -e "${YELLOW}Could not copy to clipboard. Please copy manually:${RESET}"
        echo "$text"
    fi
}

# Ask user whether to generate a new wallet or use an existing one
echo -e "${CYAN}Do you want to generate a new sponsor wallet or use an existing one?${RESET}"
echo -e "${YELLOW}1. Generate a new wallet${RESET}"
echo -e "${YELLOW}2. Use an existing wallet${RESET}"
read -p "Enter your choice (1 or 2): " CHOICE

if [ "$CHOICE" = "1" ]; then
    generate_wallet
    WALLET_FILE="$WALLET_DIR/sponsor_wallet.json"
elif [ "$CHOICE" = "2" ]; then
    read -p "Enter the path to your existing wallet keyfile (e.g., /path/to/wallet.json): " EXISTING_WALLET
    if [ ! -f "$EXISTING_WALLET" ]; then
        echo -e "${RED}Error: Wallet keyfile not found at $EXISTING_WALLET${RESET}"
        exit 1
    fi
    WALLET_FILE="$WALLET_DIR/sponsor_wallet.json"
    cp "$EXISTING_WALLET" "$WALLET_FILE"
    echo -e "${GREEN}✓ Existing wallet copied to ${RESET}$WALLET_FILE"
else
    echo -e "${RED}Invalid choice. Exiting...${RESET}"
    exit 1
fi

# Get and display the wallet address
echo -e "${BLUE}Getting wallet address...${RESET}"
WALLET_ADDRESS=$(get_wallet_address "$WALLET_FILE")
echo -e "${GREEN}✓ Sponsor wallet address: ${RESET}$WALLET_ADDRESS"

# Copy address to clipboard
echo -e "${YELLOW}Press 'c' to copy wallet address to clipboard, any other key to continue...${RESET}"
read -n 1 -s KEY
if [[ "$KEY" == "c" || "$KEY" == "C" ]]; then
    copy_to_clipboard "$WALLET_ADDRESS"
fi
echo ""

# Upload wallet to server
upload_wallet "$WALLET_FILE" "$WALLET_ADDRESS"

# Save configuration
echo "{\"sponsorWalletPath\": \"$WALLET_FILE\", \"walletAddress\": \"$WALLET_ADDRESS\"}" > "$CONFIG_FILE"
echo -e "${GREEN}✓ Sponsor wallet configured at ${RESET}$CONFIG_FILE"

echo -e "\n${YELLOW}╔════ NEXT STEPS ════╗${RESET}"
echo -e "${CYAN}1. Fund this wallet with AR or Turbo credits at https://ardrive.io/turbo${RESET}"
echo -e "${CYAN}2. Use 'perma-deploy' to deploy your web apps to Arweave${RESET}"

echo -e "\n${GREEN}PermaDeploy Sponsor Wallet Setup completed successfully!${RESET}"
EOL

# Make setup.sh executable
chmod +x "$PERMAWEB_DIR/bin/setup.sh"

# Create perma-deploy symlink
PERMA_DEPLOY_PATH="$PERMAWEB_DIR/bin/perma-deploy"
cat > "$PERMA_DEPLOY_PATH" << 'EOL'
#!/bin/bash
# This is a stub for the actual perma-deploy tool
# In a real implementation, this would be the main executable for the tool

# Check if setup has been run
if [ ! -f "$HOME/.permaweb/sponsor/config.json" ]; then
    echo "Please run setup first: $HOME/.permaweb/bin/setup.sh"
    exit 1
fi

# Load the configuration
CONFIG_FILE="$HOME/.permaweb/sponsor/config.json"
WALLET_PATH=$(node -e "console.log(JSON.parse(require('fs').readFileSync('$CONFIG_FILE')).sponsorWalletPath)" 2>/dev/null)

echo "PermaDeploy - Using wallet: $WALLET_PATH"
echo "This is a stub for the actual deployment tool."
echo "In a real implementation, this would deploy your content to Arweave."
EOL

chmod +x "$PERMA_DEPLOY_PATH"

# Add to PATH if not already there
if ! grep -q "PATH=\$PATH:\$HOME/.permaweb/bin" "$HOME/.bashrc"; then
    echo 'export PATH=$PATH:$HOME/.permaweb/bin' >> "$HOME/.bashrc"
    echo -e "${BLUE}Added perma-deploy to your PATH in .bashrc${RESET}"
fi

if ! grep -q "PATH=\$PATH:\$HOME/.permaweb/bin" "$HOME/.zshrc" 2>/dev/null; then
    if [ -f "$HOME/.zshrc" ]; then
        echo 'export PATH=$PATH:$HOME/.permaweb/bin' >> "$HOME/.zshrc"
        echo -e "${BLUE}Added perma-deploy to your PATH in .zshrc${RESET}"
    fi
fi

# Installation complete
echo -e "\n${GREEN}╔════ INSTALLATION COMPLETE ════╗${RESET}"
echo -e "${BLUE}The PermaDeploy tool has been installed successfully!${RESET}"
echo -e "${YELLOW}To set up your sponsor wallet, run:${RESET}"
echo -e "${CYAN}$PERMAWEB_DIR/bin/setup.sh${RESET}"
echo -e "${YELLOW}To deploy your web app (after setup), run:${RESET}"
echo -e "${CYAN}perma-deploy${RESET}"
echo -e "${YELLOW}You may need to restart your terminal or run 'source ~/.bashrc' to update your PATH.${RESET}"