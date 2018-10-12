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
brew "terminal-notifier"
brew "pstree"

# Editor
brew "neovim"

# Version Control
brew "git"
cask "p4merge"

# Browser
cask "firefox"

# Docker
cask "virtualbox"
cask "docker"
cask "docker-toolbox"

# Mysql
#brew "mysql", restart_service: true
cask "mysqlworkbench"

# Python
#brew "python2"
#brew "python3"

# Ruby
brew "ruby"

# Javascript
brew "nvm"

# Java
# Brew seems to upgrade cryptography to unlimited automatically, so no need to install jce extensions.
# http://www.oracle.com/technetwork/java/javase/downloads/jce8-download-2133166.html
cask "caskroom/versions/java8"
brew "maven"
# derby must be installed after java8
# unfortunately, this installs derby 10.14, but the zrest integration tests are reliant on 10.13.
# It will need to be installed manually
# brew "derby", restart_service: true

# Infrastructure
brew "nmap"

# Graphviz
brew "graphviz"

# Dev Dependencies
# brew "bwa"
# brew "samtools"
brew "imagemagick"
brew "mongoose"
brew "pandoc"
cask "mactex"

# Kubernetes
brew "kubernetes-cli"
brew "kubernetes-helm"
cask "minikube"
