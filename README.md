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

## Obsidian vault location

Neovim uses `~/Documents/obsidian/` as the default Obsidian vault. To use a
different directory on a machine, set `OBSIDIAN_VAULT` in that machine's local
shell configuration (for example, `~/.zshrc`):

```sh
export OBSIDIAN_VAULT="$HOME/Documents/my-vault"
```

Restart your shell and launch Neovim from it so Neovim inherits the variable.
Keep this setting local to each machine; no repository changes are needed when
vault locations differ. GUI launchers must also supply this environment variable
if you launch Neovim outside a terminal.

## Local usage report

After restarting Zsh and Neovim, repo command and custom mapping usage is recorded
locally. Run:

```sh
nesono-usage                    # counts and last use over the past 30 days
nesono-usage --since 7d
nesono-usage --all --category nvim
nesono-usage --category shell
```

If the checkout is not on your PATH, run `./nesono-usage` from the checkout.
The report requires Python 3.9 or later; recording requires no Python process.

Events contain only a Unix timestamp, `shell` or `nvim`, and an action label.
They are appended to `${XDG_STATE_HOME:-$HOME/.local/state}/nesono-bin/usage.tsv`
with owner-only permissions for newly created files. No data is sent anywhere.
Export `NESONO_USAGE=0` before starting Zsh/Neovim to disable recording. Delete
`usage.tsv` to reset the history. Recording errors are silently ignored.

Coverage:

- Zsh records the first command submitted at the prompt when it is a repo script,
  helper function, or recognized repo alias. This includes explicit script paths.
  It counts invocations, including failed commands, rather than successful work.
  Commands inside scripts, later commands in pipelines/compound commands,
  interpreter-prefixed calls (`bash script.sh`), and calls via `sudo` are not counted.
- Neovim records the custom mappings declared in this repo, including lazy plugin
  key specs for Snacks, Trouble, WhichKey, and Undotree. Rows use mapping descriptions
  (or key sequences when there is no description). Mappings with the same label
  share a count, including global and Fugitive-local commit shortcuts. Opening a
  prompt counts even if you cancel it. Built-in plugin mappings, automatic plugin
  behavior, and commands typed directly on the command line are not counted.
- No history is imported. An absent row means no observed usage within this coverage,
  rather than proof that a script or plugin is unused.

New Neovim mappings can use `require("config.usage").map` with the same arguments
as `vim.keymap.set`; lazy specs can use `require("config.usage").plugin(spec)`.
For other explicit actions, call `require("config.usage").record("static label")`.
Keep labels static so paths and content never enter the log.

Run telemetry checks with `python3 -m unittest discover -s tests -v`.
