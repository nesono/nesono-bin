# Personal configuration on the Dell XPS

This is the standalone Home Manager configuration for `ji` on Linux. It is
applied independently of the system configuration in `nixos_configuration`.

## What belongs where

- `nixos_configuration`: hardware, boot/encryption, system services, keyd,
  the display manager, Niri/DMS installation and the DMS session service.
- `nesono-bin/home-manager`: Zsh, personal applications, Niri layout/shortcuts,
  DMS appearance/bar settings, and Ghostty preferences.

Home Manager already manages Zsh and `~/.config/niri/config.kdl`. The latter
overrides the system-wide Niri defaults. DMS is started by the NixOS-provided
user service; do not add another `dms run` to Niri's startup commands.

## Capture the laptop's current preferences

Run these commands **on the laptop**, as `ji`, from this checkout:

```sh
cd ~/nesono-bin
mkdir -p home-manager/preferences

if [ -f "$HOME/.config/DankMaterialShell/settings.json" ]; then
  cp -L "$HOME/.config/DankMaterialShell/settings.json" home-manager/preferences/dms-settings.json
fi
if [ -f "$HOME/.config/ghostty/config" ]; then
  cp -L "$HOME/.config/ghostty/config" home-manager/preferences/ghostty-config
fi

git add home-manager/preferences
git diff --cached -- home-manager/preferences
```

Review the captured settings and commit them. DMS settings can contain personal
paths. Wallpaper image files and files referenced by Ghostty's `config-file`
setting are separate resources; copy the ones you want to preserve into the
repository and add Home Manager mappings for them too. Clipboard history and
DMS runtime/session state are intentionally not captured.

Staging matters: Git-backed flakes exclude untracked files. The mappings are
enabled only when their corresponding files are present in the flake source.
If neither file exists, your current DMS/Ghostty preferences stay unmanaged.

## Build and activate

Use Home Manager as your normal user, **without sudo**:

```sh
home-manager build --flake ~/nesono-bin/home-manager#ji
home-manager switch -b "before-hm-$(date +%Y%m%d-%H%M%S)" --flake ~/nesono-bin/home-manager#ji
```

The backup suffix preserves existing unmanaged files when Home Manager installs
its symlinks. If Home Manager is not on PATH yet, use the version pinned in this
flake instead:

```sh
nix run --inputs-from ~/nesono-bin/home-manager home-manager -- switch \
  -b "before-hm-$(date +%Y%m%d-%H%M%S)" --flake ~/nesono-bin/home-manager#ji
```

Open a new terminal for shell changes. Restart Ghostty to reload its settings,
and restart DMS from a terminal in your Niri session:

```sh
systemctl --user restart dms
```

## Change preferences afterward

The mapped files are declarative, read-only Nix-store symlinks. Edit the copies
under `home-manager/preferences/`, then run `home-manager switch --flake
~/nesono-bin/home-manager#ji` and commit your changes. Niri preferences remain in
`home-manager/niri/config.kdl`.

To experiment through a GUI again, first copy the managed configuration to a
temporary file, then move that copy over the symlink. For example, for DMS:

```sh
cp -L ~/.config/DankMaterialShell/settings.json ~/.config/DankMaterialShell/settings.json.edit
mv ~/.config/DankMaterialShell/settings.json.edit ~/.config/DankMaterialShell/settings.json
```

Restart DMS, make your changes, then capture them back into the repository before
the next activation. Use the backup-suffix activation command above to replace
the now-unmanaged file. GUI changes do not automatically update Git.
