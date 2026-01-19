#!/bin/sh

# 1. Clean up default folders created by NixOS
# rmdir ~/Documents ~/Downloads ~/Music ~/Pictures ~/Videos ~/Desktop 2>/dev/null

# 2. Symlink the "Big Data" folders from Arch
# ln -s ~/arch_home/Documents ~/Documents
# ln -s ~/arch_home/Downloads ~/Downloads
# ln -s ~/arch_home/Pictures ~/Pictures
ln -s ~/arch_home/Dropbox ~/Dropbox

# 3. Symlink your work
ln -s ~/arch_home/repos ~/repos

# 4. Symlink Configs (Create parent dir first if needed)
# mkdir -p ~/.config
# ln -s ~/arch_home/.config/nvim ~/.config/nvim
# ln -s ~/arch_home/.config/pulsar ~/.config/pulsar
# ln -s ~/arch_home/.config/dunst ~/.config/dunst
# ln -s ~/arch_home/.config/ranger ~/.config/ranger

# 5. Shared SSH keys (Optional, but useful)
# ln -s ~/arch_home/.ssh ~/.ssh

echo "Symlinking complete."
