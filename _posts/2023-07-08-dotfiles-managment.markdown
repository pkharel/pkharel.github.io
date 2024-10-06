---
layout: post 
title:  "Dotfiles management"
tags: dotfiles
---

# Storing and managing dotfiles
Use git to store and manage dotfiles like `.vimrc`, `.bashrc` and `.tmux.conf`. Documents the
process outlined [here](https://www.atlassian.com/git/tutorials/dotfiles) with minor changes and
updates.

The basic idea is that we create a Git repository in the home folder. We won't use the default
`.git` folder in case of conflicts. I'll use `.dotfiles`. We also alias a command so we can update
the dotfiles repo as needed. I use the command `dotfiles` as the alias

# Create repository to store dotfiles
Create an **EMPTY** repository somewhere online e.g [GitHub](https://github.com/pkharel/.dotfiles).

# Add dotfiles to repository
```
# Create a new empty repo for our dotfiles
git clone --bare https://<dotfiles_repo_link>.git ${HOME}/.dotfiles
# Create an alias dotfiles for dotfiles git commands
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotfiles config --local status.showUntrackedFiles no
# Add dotfiles alias to bashrc
echo "alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> $HOME/.bashrc
```

After this, you should be able to add dotfiles to the repo via something like
```
dotfiles add .tmux.conf
dotfiles add .vimrc
dotfiles add .bashrc
dotfiles commit -m "Add dotfiles"
dotfiles push -f origin master
```

# Setup dotfiles in a new machine
To setup the stored dotfiles in a new machine 
```
git clone --bare https://<dotfiles_repo_link>.git ${HOME}/.dotfiles
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
# This will give you errors if dotfiles already exist on the box so you need to remove them and
# rerun command as required
dotfiles checkout
dotfiles config status.showUntrackedFiles no
```

You can store these steps as a bash script in GitHub gists and just download and run the
[script](https://gist.githubusercontent.com/pkharel/436cdd5f0d367b8c0a5d122aa5b3ce07/raw) when
needed via something like
```
curl -Lks https://gist.githubusercontent.com/pkharel/436cdd5f0d367b8c0a5d122aa5b3ce07/raw | bash
```

# Notes
It's helpful to have auto download / auto install scripts in your `.vimrc` and `.tmux.conf` to make
the process smoother for those applications. For example

`.vimrc`
```
" Auto install Plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
```

`.tmux.conf`
```
# Auto download and install tpm if necessary
if "test ! -d ~/.tmux/plugins/tpm" \
   "run 'git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && ~/.tmux/plugins/tpm/bin/install_plugins'"
```
