#!/bin/bash

# === CONFIGURATION ===
EXTERNAL_DEVICE="/dev/sdX"   # <-- Replace with your external SSD device (e.g. /dev/sdb)
MOUNT_POINT="/mnt/external_root"
HOSTNAME="privacy-os"
USERNAME="privacyuser"
PASSWORD="SuperSecure123"     # <-- Change this to your own strong password

# === DOWNLOAD LINUX MINT ISO ===
echo "Downloading Linux Mint ISO..."
wget -O linuxmint.iso "https://mirrors.edge.kernel.org/linuxmint/stable/21.3/linuxmint-21.3-cinnamon-64bit.iso"

# === CREATE A BOOTABLE INSTALLER USB (if needed) ===
# You could write the ISO to a small USB stick to boot the installer
# Example (replace /dev/sdY with your USB stick, NOT your SSD)
# sudo dd if=linuxmint.iso of=/dev/sdY bs=4M status=progress oflag=sync

echo "Please create a bootable USB from linuxmint.iso using dd, Ventoy, or BalenaEtcher."
echo "Boot into that USB to continue installation."
echo "The next steps assume you have booted into the Linux Mint live environment."

# === INSTALL LINUX MINT TO EXTERNAL SSD ===
echo "When in live environment, open terminal and run:"
echo
echo "sudo gparted"
echo
echo "In GParted: "
echo " - Select your external SSD (e.g. /dev/sdX)"
echo " - Create a new GPT partition table"
echo " - Create an ext4 partition filling the drive"
echo " - (Optional) Create a small EFI partition if using UEFI boot (512 MB, FAT32)"
echo " - Apply changes and close GParted"
echo
echo "Then launch the Mint installer (Install Linux Mint icon)"
echo " - Choose 'Something else' in partitioning"
echo " - Select the ext4 partition for / (root)"
echo " - Choose the EFI partition for /boot/efi if created"
echo " - Set the bootloader to the external SSD (e.g. /dev/sdX)"
echo " - Complete the installation using:"
echo "     Hostname: $HOSTNAME"
echo "     Username: $USERNAME"
echo "     Password: (your chosen password)"
echo
echo "After install completes, reboot and boot into the external SSD from BIOS boot menu."

# === POST-INSTALL HARDENING ===
echo "Once booted into your external OS, run the following to set up Node.js, VSCode (VSCodium), and privacy tools:"

cat <<'EOF'
# Update system
sudo apt update && sudo apt upgrade -y

# Install basic tools
sudo apt install -y curl git ufw

# Install Node.js (LTS) and npm
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

# Verify Node.js install
node -v
npm -v

# Install VSCodium (VSCode without telemetry)
wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | sudo gpg --dearmor -o /usr/share/keyrings/vscodium-archive-keyring.gpg
echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://packages.vscodium.com/debs vscodium main' | sudo tee /etc/apt/sources.list.d/vscodium.list
sudo apt update
sudo apt install -y codium

# Set up UFW (firewall)
sudo ufw default deny outgoing
sudo ufw default deny incoming
sudo ufw allow out to any port 53  # DNS
sudo ufw allow out to any port 443 # HTTPS
sudo ufw enable

# Disable telemetry in VSCodium settings
mkdir -p ~/.config/VSCodium/User
cat <<EOT > ~/.config/VSCodium/User/settings.json
{
    "telemetry.enableTelemetry": false,
    "telemetry.enableCrashReporter": false,
    "update.mode": "none",
    "extensions.autoUpdate": false
}
EOT

# Block unwanted traffic (example: block Segment analytics)
echo "127.0.0.1 api.segment.io" | sudo tee -a /etc/hosts

# Done! Your private development environment is ready.
echo "✅ Private Node.js + VSCodium setup complete. External SSD is clean and private."
EOF

echo
echo "💡 TIP: You can add more firewall rules, or run VSCodium fully offline for best privacy."
echo "💡 When you unplug this SSD and reboot, your computer will boot into your normal OS."
