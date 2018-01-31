# Install to ~/.Brewfile
# Run with `brew bundle --global`
# Or specify the path to the file explicitly with `brew bundle --file=/path/to/Brewfile`

tap "caskroom/cask"
tap "caskroom/versions"
tap "homebrew/bundle"
tap "homebrew/core"
tap "homebrew/services"

# Shell
brew "zsh"
brew "tmux"
brew "the_silver_searcher"
brew "tree"

# Editor
brew "neovim"

# Version Control
brew "git"
cask "p4merge"

# Docker
cask "virtualbox"
cask "docker"
cask "docker-toolbox"

# Mysql
brew "mysql", restart_service: true
cask "mysqlworkbench"

# Python
brew "python2"
brew "python3"

# Ruby
brew "ruby"

# Javascript
brew "nvm"

# Java
# Don't forget to upgrade cryptography:
# http://www.oracle.com/technetwork/java/javase/downloads/jce8-download-2133166.html
cask "caskroom/versions/java8"
brew "maven"
# derby must be installed after java8
brew "derby", restart_service: true

# Graphviz
brew "graphviz"

# Dev Dependencies
brew "bwa"
brew "samtools"
brew "imagemagick"
