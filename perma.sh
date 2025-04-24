#!/bin/bash

# PermaDeploy One-Click Setup Script
# This script downloads the sponsor wallet setup script, 
# makes it executable, and runs it automatically

# ANSI colors for terminal styling
RESET="\033[0m"
BRIGHT="\033[1m"
FG_RED="\033[31m"
FG_GREEN="\033[32m"
FG_YELLOW="\033[33m"
FG_BLUE="\033[34m"
FG_MAGENTA="\033[35m"
FG_CYAN="\033[36m"
FG_WHITE="\033[37m"

echo -e "${FG_MAGENTA}
███╗   ██╗██╗████████╗██╗   ██╗ █████╗ 
████╗  ██║██║╚══██╔══╝╚██╗ ██╔╝██╔══██╗
██╔██╗ ██║██║   ██║    ╚████╔╝ ███████║
██║╚██╗██║██║   ██║     ╚██╔╝  ██╔══██║
██║ ╚████║██║   ██║      ██║   ██║  ██║
╚═╝  ╚═══╝╚═╝   ╚═╝      ╚═╝   ╚═╝  ╚═╝
                                    
${FG_WHITE}> One-Click Setup for PermaDeploy${RESET}"

echo -e "\n${BRIGHT}${FG_YELLOW}╔════ CHECKING SYSTEM REQUIREMENTS ════╗${RESET}"

# Create directories
PERMAWEB_DIR="$HOME/.permaweb"
SCRIPTS_DIR="$PERMAWEB_DIR/scripts"
mkdir -p "$SCRIPTS_DIR"
echo -e "${FG_GREEN}✓ Created scripts directory: $SCRIPTS_DIR${RESET}"

# Check for required tools
echo -e "${FG_BLUE}● Checking for required tools...${RESET}"

# Check for curl
if ! command -v curl &> /dev/null; then
    echo -e "${FG_RED}✗ curl is not installed${RESET}"
    echo -e "${FG_YELLOW}● Attempting to install curl...${RESET}"
    
    # Detect OS and install curl
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Try apt (Debian/Ubuntu)
        if command -v apt &> /dev/null; then
            sudo apt update && sudo apt install -y curl
        # Try yum (CentOS/RHEL)
        elif command -v yum &> /dev/null; then
            sudo yum install -y curl
        # Try dnf (Fedora)
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y curl
        # Try pacman (Arch Linux)
        elif command -v pacman &> /dev/null; then
            sudo pacman -Sy curl
        else
            echo -e "${FG_RED}✗ Could not install curl automatically.${RESET}"
            echo -e "${FG_YELLOW}● Please install curl manually and try again.${RESET}"
            exit 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - try to use brew
        if command -v brew &> /dev/null; then
            brew install curl
        else
            echo -e "${FG_YELLOW}● Homebrew not found. Attempting to install Homebrew...${RESET}"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            brew install curl
        fi
    else
        echo -e "${FG_RED}✗ Could not install curl. Unsupported OS.${RESET}"
        echo -e "${FG_YELLOW}● Please install curl manually and try again.${RESET}"
        exit 1
    fi
    
    # Check if installation was successful
    if ! command -v curl &> /dev/null; then
        echo -e "${FG_RED}✗ Failed to install curl.${RESET}"
        exit 1
    fi
fi
echo -e "${FG_GREEN}✓ curl is installed${RESET}"

# Check for Node.js
if ! command -v node &> /dev/null; then
    echo -e "${FG_RED}✗ Node.js is not installed${RESET}"
    echo -e "${FG_YELLOW}● Attempting to install Node.js...${RESET}"
    
    # Detect OS and install Node.js
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Try to use NVM or other installation methods
        echo -e "${FG_BLUE}● Installing Node.js using NVM...${RESET}"
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
        
        # Source NVM to use it in the current shell
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        
        # Install latest LTS version of Node.js
        nvm install --lts
        nvm use --lts
        
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - try to use brew
        if command -v brew &> /dev/null; then
            brew install node
        else
            echo -e "${FG_YELLOW}● Homebrew not found. Attempting to install Homebrew...${RESET}"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            brew install node
        fi
    else
        echo -e "${FG_RED}✗ Could not install Node.js. Unsupported OS.${RESET}"
        echo -e "${FG_YELLOW}● Please install Node.js manually from https://nodejs.org/ and try again.${RESET}"
        exit 1
    fi
    
    # Check if installation was successful
    if ! command -v node &> /dev/null; then
        echo -e "${FG_RED}✗ Failed to install Node.js.${RESET}"
        echo -e "${FG_YELLOW}● Please install Node.js manually from https://nodejs.org/ and try again.${RESET}"
        exit 1
    fi
fi
echo -e "${FG_GREEN}✓ Node.js is installed$(node --version)${RESET}"

# Check for npm
if ! command -v npm &> /dev/null; then
    echo -e "${FG_RED}✗ npm is not installed${RESET}"
    echo -e "${FG_YELLOW}● npm should be installed with Node.js. Please install Node.js properly.${RESET}"
    exit 1
fi
echo -e "${FG_GREEN}✓ npm is installed$(npm --version)${RESET}"

# Install arweave package
echo -e "${FG_BLUE}● Installing arweave package...${RESET}"
npm install -g arweave || npm install arweave

echo -e "\n${BRIGHT}${FG_YELLOW}╔════ DOWNLOADING SPONSOR WALLET SETUP SCRIPT ════╗${RESET}"

# Download the sponsor wallet setup script
WALLET_SCRIPT="$SCRIPTS_DIR/sponsor-wallet-setup.sh"

echo -e "${FG_BLUE}● Downloading sponsor wallet setup script...${RESET}"

# Here you would replace this with your actual URL where the script is hosted
# For now, we'll just create the script with the content provided
cat > "$WALLET_SCRIPT" << 'EOL'
#!/bin/bash

# PermaDeploy Sponsor Wallet Setup Script

# ANSI colors for terminal styling
RESET="\033[0m"
BRIGHT="\033[1m"
DIM="\033[2m"
FG_BLACK="\033[30m"
FG_RED="\033[31m"
FG_GREEN="\033[32m"
FG_YELLOW="\033[33m"
FG_BLUE="\033[34m"
FG_MAGENTA="\033[35m"
FG_CYAN="\033[36m"
FG_WHITE="\033[37m"
BG_BLACK="\033[40m"
BG_RED="\033[41m"
BG_GREEN="\033[42m"
BG_YELLOW="\033[43m"
BG_BLUE="\033[44m"
BG_MAGENTA="\033[45m"
BG_CYAN="\033[46m"
BG_WHITE="\033[47m"

# Define the sponsor wallet directory
SPONSOR_DIR="$HOME/.permaweb/sponsor"
WALLET_DIR="$SPONSOR_DIR/wallets"
CONFIG_FILE="$SPONSOR_DIR/config.json"

# Function to print title
print_title() {
  echo -e "${FG_MAGENTA}
    ███╗   ██╗██╗████████╗██╗   ██╗ █████╗ 
    ████╗  ██║██║╚══██╔══╝╚██╗ ██╔╝██╔══██╗
    ██╔██╗ ██║██║   ██║    ╚████╔╝ ███████║
    ██║╚██╗██║██║   ██║     ╚██╔╝  ██╔══██║
    ██║ ╚████║██║   ██║      ██║   ██║  ██║
    ╚═╝  ╚═══╝╚═╝   ╚═╝      ╚═╝   ╚═╝  ╚═╝
                                            
    ${FG_WHITE}> Permanently deploy your web apps to the decentralized Arweave network${RESET}
    ${FG_CYAN}    
    ┌────┐        ┌────┐
    │${FG_BLUE}████${FG_CYAN}│━━━━━━━━│${FG_BLUE}████${FG_CYAN}│     ${FG_WHITE}SPONSOR WALLET SETUP${FG_CYAN}
    └────┘╲      ╱└────┘     ${FG_WHITE}DECENTRALIZED${FG_CYAN}
           ╲    ╱
            ╲  ╱
           ┌────┐
           │${FG_BLUE}████${FG_CYAN}│
           └────┘
         ${RESET}"
}

# Function to make wallet address copyable
make_wallet_copyable() {
  local wallet_address="$1"
  
  echo -e "\n${BG_BLACK}${FG_WHITE} $wallet_address ${RESET}"
  echo -e "${FG_YELLOW}Press 'c' to copy wallet address to clipboard, any other key to continue...${RESET}"
  
  # Read a single character
  read -n 1 -s key
  
  if [[ "$key" == "c" || "$key" == "C" ]]; then
    # Different copy commands based on OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
      # macOS
      echo -n "$wallet_address" | pbcopy
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
      # Windows
      echo -n "$wallet_address" | clip
    else
      # Linux and others
      if command -v xsel &> /dev/null; then
        echo -n "$wallet_address" | xsel -ib
      elif command -v xclip &> /dev/null; then
        echo -n "$wallet_address" | xclip -selection clipboard
      elif command -v wl-copy &> /dev/null; then
        echo -n "$wallet_address" | wl-copy
      else
        echo -e "${FG_RED}No clipboard utility found. Please copy manually.${RESET}"
        return 1
      fi
    fi
    echo -e "${FG_GREEN}\nWallet address copied to clipboard!${RESET}"
  fi
}

# Function to show progress bar
progress_bar() {
  local percent="$1"
  local width=30
  local filled=$(( width * percent / 100 ))
  local empty=$(( width - filled ))
  
  printf "${FG_GREEN}[" 
  printf '%*s' "$filled" | tr ' ' '█'
  printf "${FG_RED}"
  printf '%*s' "$empty" | tr ' ' ' '
  printf "] ${percent}%%${RESET}\r"
  
  if [[ $percent -eq 100 ]]; then
    echo
  fi
}

# Function to generate a new Arweave wallet
generate_wallet() {
  echo -e "${FG_BLUE}Generating a new Arweave wallet...${RESET}"
  local WALLET_FILE="$WALLET_DIR/sponsor_wallet.json"
  
  # Show progress
  for i in {0..100..10}; do
    progress_bar $i
    sleep 0.1
  done
  
  node -e "const Arweave = require('arweave'); Arweave.init().wallets.generate().then(key => console.log(JSON.stringify(key))).catch(err => console.error(err));" > "$WALLET_FILE" 2>/dev/null
  
  if [ $? -ne 0 ]; then
    echo -e "${FG_RED}Error: Failed to generate wallet.${RESET}"
    return 1
  fi
  
  progress_bar 100
  echo -e "${FG_GREEN}New wallet generated at $WALLET_FILE${RESET}"
  return 0
}

# Function to get wallet address from keyfile
get_wallet_address() {
  local wallet_file="$1"
  local WALLET_ADDRESS=$(node -e "const fs = require('fs'); const Arweave = require('arweave'); Arweave.init().wallets.jwkToAddress(JSON.parse(fs.readFileSync('$wallet_file'))).then(addr => console.log(addr)).catch(err => console.error(err));" 2>/dev/null)
  
  if [ -z "$WALLET_ADDRESS" ]; then
    echo -e "${FG_RED}Error: Could not derive wallet address from $wallet_file.${RESET}" >&2
    return 1
  fi
  
  echo "$WALLET_ADDRESS"
}

# Function to upload wallet to server
upload_wallet() {
  local wallet_file="$1"
  local wallet_address="$2"
  local API_KEY="sponsor-api-key-456" # API key for wallet sponsor
  local SERVER_URL="http://localhost:3000/upload-wallet"
  
  echo -e "${FG_BLUE}Uploading wallet to server...${RESET}"
  
  # Show progress
  for i in {0..50..10}; do
    progress_bar $i
    sleep 0.1
  done
  
  local RESPONSE=$(curl -s -o response.json -w "%{http_code}" -X POST \
      -H "X-API-Key: $API_KEY" \
      -F "wallet=@$wallet_file" \
      "$SERVER_URL")
      
  if [ "$RESPONSE" -ne 200 ]; then
    progress_bar 100
    echo -e "${FG_RED}Error: Failed to upload wallet to server. HTTP status: $RESPONSE${RESET}"
    cat response.json
    rm response.json
    return 1
  fi
  
  local UPLOADED_ADDRESS=$(node -e "const fs = require('fs'); console.log(JSON.parse(fs.readFileSync('response.json')).walletAddress);" 2>/dev/null)
  rm response.json
  
  # Show more progress
  for i in {60..100..10}; do
    progress_bar $i
    sleep 0.1
  done
  
  if [ "$UPLOADED_ADDRESS" != "$wallet_address" ]; then
    echo -e "${FG_RED}Error: Uploaded wallet address mismatch.${RESET}"
    return 1
  fi
  
  echo -e "${FG_GREEN}Wallet uploaded successfully. Address: $UPLOADED_ADDRESS${RESET}"
  return 0
}

# Main function
main() {
  # Clear screen
  clear
  
  # Print title
  print_title
  
  echo -e "\n${BRIGHT}${FG_YELLOW}╔════ SPONSOR WALLET SETUP ════╗${RESET}"
  echo -e "${FG_CYAN}● Starting PermaDeploy Sponsor Wallet Setup...${RESET}"
  
  # Create directories if they don't exist
  mkdir -p "$SPONSOR_DIR" "$WALLET_DIR"
  echo -e "${FG_BLUE}● Configuration directory: $SPONSOR_DIR${RESET}"
  
  # Check prerequisites
  echo -e "\n${BRIGHT}${FG_YELLOW}╔════ CHECKING PREREQUISITES ════╗${RESET}"
  
  # Check if Node.js is installed
  if ! command -v node &> /dev/null; then
    echo -e "${FG_RED}✗ Error: Node.js is required. Please install it:${RESET}"
    echo -e "  - Linux: ${FG_BLUE}sudo apt install nodejs${RESET}"
    echo -e "  - macOS: ${FG_BLUE}brew install node${RESET}"
    echo -e "  - Windows: Visit ${FG_BLUE}https://nodejs.org/${RESET}"
    exit 1
  else
    echo -e "${FG_GREEN}✓ Node.js is installed${RESET}"
  fi
  
  # Check if curl is installed
  if ! command -v curl &> /dev/null; then
    echo -e "${FG_RED}✗ Error: curl is required. Please install it:${RESET}"
    echo -e "  - Linux: ${FG_BLUE}sudo apt install curl${RESET}"
    echo -e "  - macOS: ${FG_BLUE}brew install curl${RESET}"
    echo -e "  - Windows: Visit ${FG_BLUE}https://curl.se/windows/${RESET}"
    exit 1
  else
    echo -e "${FG_GREEN}✓ curl is installed${RESET}"
  fi
  
  # Check if arweave package is installed
  echo -e "${FG_BLUE}● Checking arweave package...${RESET}"
  if ! npm list -g arweave &> /dev/null && ! npm list arweave &> /dev/null; then
    echo -e "${FG_YELLOW}⚠ Installing arweave package...${RESET}"
    npm install -g arweave
    if [ $? -ne 0 ]; then
      echo -e "${FG_RED}✗ Failed to install arweave package globally. Trying local install...${RESET}"
      npm install arweave
      if [ $? -ne 0 ]; then
        echo -e "${FG_RED}✗ Failed to install arweave package. Please try manually:${RESET}"
        echo -e "  ${FG_BLUE}npm install -g arweave${RESET}"
        exit 1
      fi
    fi
  else
    echo -e "${FG_GREEN}✓ arweave package is installed${RESET}"
  fi
  
  # Ask user whether to generate a new wallet or use an existing one
  echo -e "\n${BRIGHT}${FG_YELLOW}╔════ WALLET SELECTION ════╗${RESET}"
  echo -e "${FG_WHITE}Do you want to generate a new sponsor wallet or use an existing one?${RESET}"
  echo -e "${FG_CYAN}1.${RESET} Generate a new wallet"
  echo -e "${FG_CYAN}2.${RESET} Use an existing wallet"
  
  read -p "$(echo -e "${FG_YELLOW}> Enter your choice (1 or 2): ${RESET}")" CHOICE
  
  if [ "$CHOICE" = "1" ]; then
    echo -e "\n${BRIGHT}${FG_YELLOW}╔════ GENERATING NEW WALLET ════╗${RESET}"
    generate_wallet
    if [ $? -ne 0 ]; then
      echo -e "${FG_RED}✗ Wallet generation failed.${RESET}"
      exit 1
    fi
    WALLET_FILE="$WALLET_DIR/sponsor_wallet.json"
  elif [ "$CHOICE" = "2" ]; then
    echo -e "\n${BRIGHT}${FG_YELLOW}╔════ USING EXISTING WALLET ════╗${RESET}"
    read -p "$(echo -e "${FG_YELLOW}> Enter the path to your existing wallet keyfile: ${RESET}")" EXISTING_WALLET
    
    if [ ! -f "$EXISTING_WALLET" ]; then
      echo -e "${FG_RED}✗ Error: Wallet keyfile not found at $EXISTING_WALLET${RESET}"
      exit 1
    fi
    
    WALLET_FILE="$WALLET_DIR/sponsor_wallet.json"
    cp "$EXISTING_WALLET" "$WALLET_FILE"
    echo -e "${FG_GREEN}✓ Existing wallet copied to $WALLET_FILE${RESET}"
  else
    echo -e "${FG_RED}✗ Invalid choice. Exiting...${RESET}"
    exit 1
  fi
  
  # Get and display the wallet address
  echo -e "\n${BRIGHT}${FG_YELLOW}╔════ WALLET ADDRESS ════╗${RESET}"
  WALLET_ADDRESS=$(get_wallet_address "$WALLET_FILE")
  if [ $? -ne 0 ]; then
    echo "$WALLET_ADDRESS" # Output error message
    exit 1
  fi
  
  echo -e "${FG_GREEN}✓ Sponsor wallet address:${RESET}"
  make_wallet_copyable "$WALLET_ADDRESS"
  
  # Upload wallet to server
  echo -e "\n${BRIGHT}${FG_YELLOW}╔════ UPLOADING WALLET ════╗${RESET}"
  upload_wallet "$WALLET_FILE" "$WALLET_ADDRESS"
  if [ $? -ne 0 ]; then
    echo -e "${FG_RED}✗ Wallet upload failed.${RESET}"
    exit 1
  fi
  
  # Save configuration for perma-deploy.js
  echo "{\"sponsorWalletPath\": \"$WALLET_FILE\"}" > "$CONFIG_FILE"
  echo -e "${FG_GREEN}✓ Sponsor wallet configured at $CONFIG_FILE${RESET}"
  
  echo -e "\n${BRIGHT}${FG_GREEN}╔════ SETUP COMPLETED! ════╗${RESET}"
  echo -e "${FG_WHITE}Please fund this wallet with AR or Turbo credits:${RESET}"
  make_wallet_copyable "$WALLET_ADDRESS"
  echo -e "\n${FG_CYAN}● Visit ${FG_BLUE}https://ardrive.io/turbo${FG_CYAN} to fund your wallet${RESET}"
  echo -e "${FG_GREEN}✓ PermaDeploy Sponsor Wallet Setup completed successfully!${RESET}"
}

# Run the main function
main

exit 0
EOL

# Make the script executable
chmod +x "$WALLET_SCRIPT"
echo -e "${FG_GREEN}✓ Made script executable${RESET}"

echo -e "\n${BRIGHT}${FG_YELLOW}╔════ CREATING SHORTCUT COMMAND ════╗${RESET}"

# Create a symlink to the script in a directory that's in the PATH
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo -e "${FG_YELLOW}⚠ Adding $BIN_DIR to your PATH${RESET}"
    
    # Add to PATH based on shell
    if [[ -f "$HOME/.bashrc" ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        source "$HOME/.bashrc"
    elif [[ -f "$HOME/.zshrc" ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
        source "$HOME/.zshrc"
    fi
    
    # Set for current session
    export PATH="$HOME/.local/bin:$PATH"
fi

ln -sf "$WALLET_SCRIPT" "$BIN_DIR/permadeploy-setup"
echo -e "${FG_GREEN}✓ Created command: permadeploy-setup${RESET}"

echo -e "\n${BRIGHT}${FG_GREEN}╔════ INSTALLATION COMPLETE! ════╗${RESET}"
echo -e "${FG_WHITE}The PermaDeploy Sponsor Wallet Setup script has been installed.${RESET}"
echo -e "${FG_CYAN}● You can run it anytime with:${RESET} ${FG_YELLOW}permadeploy-setup${RESET}"

echo -e "\n${BRIGHT}${FG_YELLOW}╔════ RUNNING SETUP NOW ════╗${RESET}"
echo -e "${FG_CYAN}● Would you like to run the setup now? (y/n)${RESET}"
read -p "$(echo -e "${FG_YELLOW}> ${RESET}")" START_NOW

if [[ "$START_NOW" == "y" || "$START_NOW" == "Y" || "$START_NOW" == "yes" || "$START_NOW" == "Yes" ]]; then
    echo -e "${FG_GREEN}✓ Starting PermaDeploy Sponsor Wallet Setup...${RESET}"
    "$WALLET_SCRIPT"
else
    echo -e "${FG_BLUE}● Setup can be run later with: ${FG_YELLOW}permadeploy-setup${RESET}"
fi

exit 0