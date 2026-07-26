#!/usr/bin/env bash

# Polybar Installation Script for ani-bar
# This script automates the installation of Polybar and its dependencies,
# and sets up the ani-bar configuration.

# --- Functions ---

# Function to display messages
log() {
    echo "--> $1"
}

# Function to display errors and exit
error_exit() {
    echo "!!! ERROR: $1" >&2
    exit 1
}

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# --- Main Script ---

log "Starting Polybar ani-bar installation..."

# 1. Detect Operating System and Package Manager
OS=""
PKG_MANAGER=""

if command_exists "pacman"; then
    OS="Arch"
    PKG_MANAGER="pacman"
    log "Detected Arch Linux."
elif command_exists "apt"; then
    OS="Debian"
    PKG_MANAGER="apt"
    log "Detected Debian/Ubuntu based system."
else
    error_exit "Unsupported operating system. This script supports Arch Linux and Debian/Ubuntu."
fi

# 2. Install Dependencies
log "Installing dependencies..."

if [ "$OS" == "Arch" ]; then
    DEPENDENCIES=(
        "polybar"
        "feh"
        "python-pipx" # For pywal
        "libnotify"
        "pulseaudio-alsa" # For pulseaudio-utils functionality
        "iproute2"
        "pacman-contrib"
    )
    MISSING_DEPS=()
    for dep in "${DEPENDENCIES[@]}"; do
        if ! pacman -Q "$dep" &> /dev/null; then
            MISSING_DEPS+=("$dep")
        fi
    done

    if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
        log "Missing Arch dependencies: ${MISSING_DEPS[*]}"
        log "Attempting to install them. You may be prompted for your sudo password."
        sudo pacman -Syu "${MISSING_DEPS[@]}" || error_exit "Failed to install Arch dependencies."
    else
        log "All Arch dependencies are already installed."
    fi

elif [ "$OS" == "Debian" ]; then
    DEPENDENCIES=(
        "polybar"
        "feh"
        "python3-pip" # For pywal
        "libnotify-bin"
        "pulseaudio-utils"
        "iproute2"
    )
    MISSING_DEPS=()
    for dep in "${DEPENDENCIES[@]}"; do
        if ! dpkg -s "$dep" &> /dev/null; then
            MISSING_DEPS+=("$dep")
        fi
    done

    if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
        log "Missing Debian/Ubuntu dependencies: ${MISSING_DEPS[*]}"
        log "Attempting to install them. You may be prompted for your sudo password."
        sudo apt update || error_exit "Failed to update apt repositories."
        sudo apt install -y "${MISSING_DEPS[@]}" || error_exit "Failed to install Debian/Ubuntu dependencies."
    else
        log "All Debian/Ubuntu dependencies are already installed."
    fi
fi

# Install pywal separately using pipx
log "Installing/updating pywal..."
if command_exists "pipx"; then
    pipx install pywal || error_exit "Failed to install pywal with pipx."
else
    error_exit "'pipx' not found. Please ensure 'python-pipx' is installed and in your PATH."
fi
log "Pywal installed successfully."

# 3. Clone/Copy Repository
log "Setting up Polybar configuration..."
CONFIG_DIR="/home/${SUDO_USER:-${USER}}/.config/polybar"
CURRENT_DIR="$(dirname "$(readlink -f "$0")")"

if [ -d "$CONFIG_DIR" ]; then
    log "Existing Polybar configuration found at $CONFIG_DIR. Backing it up to $CONFIG_DIR.bak"
    mv "$CONFIG_DIR" "$CONFIG_DIR.bak" || error_exit "Failed to backup existing Polybar config."
fi

log "Copying ani-bar configuration to $CONFIG_DIR..."
cp -r "$CURRENT_DIR" "$CONFIG_DIR" || error_exit "Failed to copy ani-bar configuration."
log "Configuration copied successfully."

# 4. Make Scripts Executable
log "Making custom scripts executable..."
chmod +x "$CONFIG_DIR/scripts/"* || error_exit "Failed to make scripts executable."
log "Custom scripts are now executable."

# 5. Provide Launch Instructions
log "Installation complete!"
log "To launch Polybar, run:"
log "  $CONFIG_DIR/launch.sh"
log ""
log "To make Polybar start automatically with your window manager, add the above command"
log "to your window manager's autostart file (e.g., ~/.config/i3/config for i3,"
log "~/.xinitrc for others, or your desktop environment's autostart settings)."
log ""
log "Remember to install Nerd Fonts for proper icon display and run 'fc-cache -fv' afterwards."
log "If you use pywal, run 'wal -i /path/to/your/wallpaper.jpg' to generate colors."
log ""
log "Enjoy your new Polybar setup!"
