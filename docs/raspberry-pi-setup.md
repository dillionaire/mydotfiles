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

2. Clone dotfiles:
   ```bash
   git clone https://github.com/dillionaire/mydotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

3. Run the installer:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

## ARM-specific Considerations

### Python Package Management

1. Install UV:
   ```bash
   # Option 1: Using pip
   curl -LsSf https://astral.sh/uv/install.sh | sh

   # Option 2: From source
   git clone https://github.com/astral/uv.git
   cd uv
   cargo install --path .
   ```

2. Install Python packages:
   ```bash
   uv pip install jupyter ipython matplotlib
   ```

### Node.js Setup

1. Install Node.js using NVM:
   ```bash
   # Install LTS version compatible with ARM
   nvm install --lts
   nvm use --lts
   ```

### Docker Setup

1. Install Docker:
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   sudo usermod -aG docker $USER
   ```

## Testing

1. Test ZSH configuration:
   ```bash
   # Change default shell to zsh
   chsh -s $(which zsh)
   
   # Start new shell
   zsh
   
   # Test Oh My Zsh plugins
   # Auto-suggestions should appear as you type
   # Syntax highlighting should be visible
   ```

2. Test Python environment:
   ```bash
   # Test UV
   uv --version
   
   # Test Python packages
   python3 -c "import jupyter, matplotlib"
   ```

3. Test Node.js:
   ```bash
   node --version
   npm --version
   ```

4. Test VS Code:
   ```bash
   # If using VS Code Remote SSH:
   code --version
   ```

## Common Issues

### UV Installation
- If UV binary installation fails, try building from source using Rust
- Ensure you're using the ARM64 version if available

### Performance Optimization
- Reduce Oh My Zsh plugins on Raspberry Pi for better performance
- Consider using a lighter theme
- Add to `.zshrc` for Raspberry Pi:
  ```bash
  # Raspberry Pi Performance Optimizations
  DISABLE_AUTO_UPDATE=true
  ZSH_DISABLE_COMPFIX=true
  ```

### Memory Management
- Create a swap file if running memory-intensive applications:
  ```bash
  sudo fallocate -l 1G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  ```

## Cleanup

To remove the test setup:
```bash
# Revert to bash
chsh -s $(which bash)

# Remove dotfiles
rm -rf ~/.dotfiles

# Remove Oh My Zsh
uninstall_oh_my_zsh

# Remove other configurations
rm -rf ~/.config/vscode
rm -f ~/.zshrc ~/.bash_profile ~/.zprofile
```
