#/bin/bash

CWD=$(pwd)

cp -irf $CWD/.xinitrc ~/
cp -irf $CWD/.Xdefaults ~/
cp -irf $CWD/.bashrc ~/
cp -irf $CWD/.conkyrc ~/
cp -irf $CWD/.i3/config ~/.i3/
cp -irf $CWD/.i3/pacman_updates.sh ~/.i3/
cp -irf $CWD/.i3/conky-i3bar.sh ~/.i3/
cp -irf $CWD/.vimrc ~/
cp -irf $CWD/.gitignore_global ~/
cp -rf $CWD/.vim ~/
