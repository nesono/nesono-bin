# README

## Removing obsolete integrations

Run `bash cleanup_obsolete_integrations.sh` to preview cleanup, then run it with
`--apply` to apply it. Run it from the checkout used for the original installation.
It archives repository-owned configuration links and tmux plugins under
`~/.local/state/nesono-bin/`, backs up Fish configuration before removing nesono-bin
entries, and clears Fish universal path entries when Fish is available. Regular
configuration files and unrelated links are preserved. Applications are not
uninstalled. Restart any open Fish sessions after cleanup; if Fish is unavailable,
its universal variables are left untouched until cleanup is rerun with Fish installed.
Cleanup also archives repository-owned `~/.tigrc`, `~/.vimrc`, and `~/.vim` links.
Neovim remains supported; the plain Vim configuration and Windows installer have
been removed.

## Description

Useful helper scripts and personal doffiles for all purposes. See the documentation and comments in
each file for usage.

## Installation

The repository could be (but is not restricted to be) cloned into the home directory of the user, e.g. by
```
cd ~/
git clone git://github.com/nesono/nesono-bin.git
```

For installation (sourcing in original dotfiles, etc.)
simply invoke
```
~/nesono-bin/install_nesono-bin
```

The installation script might be invoked several times without
harming your settings.

For a nice git setup (git needs to be installed already), invoke
```
git_setup.sh
```
