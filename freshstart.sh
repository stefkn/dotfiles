#!/bin/sh

# Thanks to @dresvints - https://github.com/driesvints/dotfiles

echo "Setting up your Mac..."

# Check if Xcode Command Line Tools are installed
if ! xcode-select -p &>/dev/null; then
  echo "Xcode Command Line Tools not found. Installing..."
  xcode-select --install
else
  echo "Xcode Command Line Tools already installed."
fi

# Check for Oh My Zsh and install if we don't have it
if test ! $(which omz); then
  /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)"
fi

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Removes .zshrc from $HOME (if it exists) and symlinks the .zshrc file from the .dotfiles
rm -rf $HOME/.zshrc
ln -sw $HOME/.dotfiles/.zshrc $HOME/.zshrc

# Update Homebrew recipes
brew update

# Install all our dependencies with bundle (See Brewfile)
brew tap homebrew/bundle
brew bundle --file ./Brewfile

# Create a projects directories
mkdir $HOME/projects

# Set macOS preferences - we will run this last because this will reload the shell
source ./.macos

# Create an Alacritty config file and config directory
touch $HOME/.alacritty.toml
mkdir ~/.config && mkdir ~/.config/alacritty

# move the theme to the alacritty directory
cp aura-theme.toml ~/.config/alacritty/aura-theme.toml

# add the theme to the alacritty config
echo "[general]\nimport = ['~/.config/alacritty/aura-theme.toml']\n\n[window]\nopacity = 0.55\nblur = true" >> $HOME/.alacritty.toml

# Remove all apps from the dock and restart
defaults write com.apple.dock persistent-apps -array; killall Dock

echo "Done, welcome to your new machine."
