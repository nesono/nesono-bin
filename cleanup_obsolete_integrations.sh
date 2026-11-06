#!/usr/bin/env bash
set -euo pipefail

apply=false
case "${1:-}" in
  --apply) apply=true ;;
  ''|--dry-run) ;;
  *) echo "Usage: $0 [--dry-run|--apply]" >&2; exit 2 ;;
esac
repo=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
backup="${HOME}/.local/state/nesono-bin/cleanup-$(date +%Y%m%d-%H%M%S)-$$"

archive() {
  printf 'Archive %s\n' "$1"
  if "$apply"; then
    mkdir -p "$backup/$(dirname "${1#"$HOME"/}")"
    mv "$1" "$backup/${1#"$HOME"/}"
  fi
}

# Match links lexically: their repository targets may already have been deleted.
for entry in .Xresources:Xresources .tmux.conf:tmux.conf \
  .config/regolith2:regolith2 .config/i3:i3 .config/i3status:i3status \
  .config/i3status-rust:i3status-rust .config/polybar:polybar \
  .config/rofi:rofi .config/dunst:dunst .config/picom.conf:picom.conf \
  .config/hypr:hypr .config/wlogout:wlogout; do
  destination="$HOME/${entry%%:*}"
  target="$repo/${entry#*:}"
  if [[ -L "$destination" ]]; then
    actual=$(readlink "$destination")
    if [[ "$actual" == "$target" || "$actual" == "$target/" ]]; then
      archive "$destination"
    else
      printf 'Keep unrelated link %s\n' "$destination"
    fi
  fi
done

fishconfig="$HOME/.config/fish/config.fish"
if [[ -f "$fishconfig" ]] && grep -Eq 'NESONOBININSTALLATIONDIR|fishtils/' "$fishconfig"; then
  printf 'Clean nesono-bin entries from %s (backup original)\n' "$fishconfig"
  if "$apply"; then
    mkdir -p "$backup/.config/fish"
    cp -p "$fishconfig" "$backup/.config/fish/config.fish"
    sed '/^# the nesono script directory$/d; /^set -U NESONOBININSTALLATIONDIR /d; /^test -d .*NESONOBININSTALLATIONDIR.*fish_user_paths/d; /^\. .*NESONOBININSTALLATIONDIR\/fishtils\/aliases$/d; /^\. .*NESONOBININSTALLATIONDIR\/fishtils\/config.fish$/d' \
      "$backup/.config/fish/config.fish" > "$fishconfig"
  fi
fi

# Preserve plugin checkouts and local changes by moving the entire directory.
if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
  archive "$HOME/.tmux/plugins"
fi
if command -v fish >/dev/null 2>&1; then
  printf 'Remove this repository from Fish universal paths and erase its installation variable\n'
  if "$apply"; then
    # Fish expands these variables, not the calling Bash shell.
    # shellcheck disable=SC2016
    fish --no-config -c '
      set -l kept
      for p in $fish_user_paths
        if test "$p" != "$argv[1]"
          set -a kept "$p"
        end
      end
      set -U fish_user_paths $kept
      set -eU NESONOBININSTALLATIONDIR
    ' "$repo"
  fi
fi
if "$apply"; then
  printf 'Cleanup complete. Backups, if any: %s\n' "$backup"
else
  printf 'Preview only. Run with --apply to perform cleanup.\n'
fi
