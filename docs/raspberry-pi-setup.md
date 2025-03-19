# Testing Dotfiles on Raspberry Pi

## Prerequisites

1. A Raspberry Pi (any model with ARMv7 or later)
2. Raspberry Pi OS (64-bit recommended)
3. Internet connection
4. SSH access to your Pi (optional but recommended)

## Initial Setup

1. Flash Raspberry Pi OS:
   ```bash
   # On your main computer
   # Download and use Raspberry Pi Imager from:
   # https://www.raspberrypi.com/software/
   ```

2. Enable SSH (if needed):
   - Create an empty file named `ssh` in the boot partition
   - Or enable through Raspberry Pi Imager settings

3. Connect to your Pi:
   ```bash
   ssh pi@raspberrypi.local
   # Default password is 'raspberry'
   ```

## Installation

1. Install essential packages:
   ```bash
   sudo apt update
   sudo apt install -y git zsh curl python3-pip
   ```

2. Switch to Zsh (BEFORE installing dotfiles):
   ```bash
   # Make zsh your default shell
   chsh -s $(which zsh)
   
   # Log out and log back in, or restart your SSH session
   exit
   # Reconnect via SSH...
   
   # Verify you're now using zsh
   echo $SHELL
   # Should output: /usr/bin/zsh or similar
   ```

3. Clone and install dotfiles:
   ```bash
   git clone https://github.com/dillionaire/mydotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   chmod +x install.sh
   ./install.sh
   ```

4. Apply changes:
   ```bash
   source ~/.zshrc
   ```

## Verifying the Setup

1. Check Oh My Zsh:
   ```bash
   echo $ZSH_VERSION  # Should show zsh version
   echo $ZSH_THEME    # Should show 'af-magic'
   ```

2. Test plugins:
   ```bash
   # Type a command you've used before - should show suggestions
   # Use git commands - should show completions
   git st  # Should auto-expand to 'git status'
   ```

## ARM-specific Considerations

[Rest of the ARM-specific content remains the same...]

## Troubleshooting

### Shell Switch Issues

If you see 'zsh: not found' or similar errors:
```bash
# Verify zsh installation
sudo apt install -y zsh

# Verify shell availability
cat /etc/shells

# Try switching shells again
sudo chsh -s $(which zsh) $USER
```

If Oh My Zsh installation fails:
```bash
# Remove any partial Oh My Zsh installation
rm -rf ~/.oh-my-zsh

# Start fresh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

[Rest of the troubleshooting content remains the same...]
