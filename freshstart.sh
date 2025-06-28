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

# Set default MySQL root password and auth type
mysql -u root -e "ALTER USER root@localhost IDENTIFIED WITH mysql_native_password BY 'password'; FLUSH PRIVILEGES;"

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
echo "import = ["~/.config/alacritty/aura-theme.toml"]" >> $HOME/.alacritty.toml

# Remove all apps from the dock and restart
defaults write com.apple.dock persistent-apps -array; killall Dock

echo "Done, welcome to your new machine."
