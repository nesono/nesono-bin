{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  home.username = "wuzz";
  home.homeDirectory = "/home/wuzz";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    btop
    prek
    ghostty
    lazygit
    nerd-fonts.jetbrains-mono
    nextcloud-client
    nodejs
    (writeShellScriptBin "opencode" ''
      exec ${nodejs}/bin/npx -y opencode-ai@latest "$@"
    '')
    obsidian
    planify
    playerctl
    thunderbird
    viu
    zoxide
  ];

  home.sessionVariables = {
    NESONOBININSTALLATIONDIR = "${config.home.homeDirectory}/nesono-bin";
    EDITOR = "nvim";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.opencode/bin"
  ];

  # Also apply Caps -> Ctrl to GNOME sessions.
  dconf = {
    enable = true;

    settings."org/gnome/desktop/input-sources" = {
      xkb-options = [ "ctrl:nocaps" ];
    };
  };

  programs.zsh = {
    enable = true;

    initContent = ''
      . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
      . "$HOME/nesono-bin/zshrc"
    '';
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship.enable = true;

  programs.zellij = {
    enable = true;
    enableZshIntegration = false;
  };

  #
  # Dank Material Shell
  #
  programs.dank-material-shell = {
    enable = true;
	
	# Use nixpkgs' niri package instead of niri-flake's package.
    # niri-flake currently depends on removed libdisplay-info_0_2.
    package = pkgs.niri;

    # Have the DMS niri module start DMS.
    niri = {
      enableSpawn = true;

      # We define our bindings declaratively below instead of including
      # DMS-generated KDL files.
      enableKeybinds = false;

      includes.enable = false;
    };
  };

  #
  # niri
  #
  programs.niri = {
    enable = true;

    settings = {
      input = {
        keyboard = {
          xkb.options = "ctrl:nocaps";
          numlock = true;
        };

        touchpad = {
          tap = true;
          natural-scroll = true;
        };

        mouse = {
          accel-speed = -1.0;
          accel-profile = "flat";
          scroll-factor = 0.5;
        };
      };

      layout = {
        gaps = 16;
        center-focused-column = "never";

        preset-column-widths = [
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
        ];

        default-column-width = {
          proportion = 0.5;
        };

        focus-ring = {
          enable = true;
          width = 3;

          active.color = "#7fc8ff80";
          inactive.color = "#00000000";
        };

        border = {
          enable = false;
          width = 4;

          active.color = "#ffc87f";
          inactive.color = "#505050";
          urgent.color = "#9b0000";
        };

        shadow = {
          enable = true;
          softness = 30;
          spread = 5;

          offset = {
            x = 0;
            y = 5;
          };

          color = "#0007";
        };
      };

      screenshot-path =
        "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

      #
      # Window rules from your old config.kdl
      #
      window-rules = [
        {
          matches = [
            {
              app-id = "^org\\.wezfurlong\\.wezterm$";
            }
          ];

          default-column-width = { };
        }

        {
          matches = [
            {
              app-id = "firefox$";
              title = "^Picture-in-Picture$";
            }
          ];

          open-floating = true;
        }
      ];

      #
      # Keybindings
      #
      binds = {
        "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];

        #
        # Applications / DMS
        #
        "Mod+T" = {
          hotkey-overlay.title = "Open a Terminal: ghostty";
          action.spawn = [ "ghostty" ];
        };

        "Super+Alt+L" = {
          hotkey-overlay.title = "Lock the Screen: DMS";
          action.spawn = [
            "dms"
            "ipc"
            "call"
            "lock"
            "lock"
          ];
        };

        "Super+Alt+C" = {
          hotkey-overlay.title = "Clipboard Manager: DMS";
          action.spawn = [
            "dms"
            "ipc"
            "call"
            "clipboard"
            "toggle"
          ];
        };

        "Super+Alt+N" = {
          hotkey-overlay.title = "Notifications: DMS";
          action.spawn = [
            "dms"
            "ipc"
            "call"
            "notifications"
            "open"
          ];
        };

        "Super+Alt+Space" = {
          hotkey-overlay.title = "Control Center: DMS";
          action.spawn = [
            "dms"
            "ipc"
            "call"
            "control-center"
            "toggle"
          ];
        };

        "Super+Space" = {
          hotkey-overlay.title = "Application Launcher";
          action.spawn = [
            "dms"
            "ipc"
            "call"
            "spotlight"
            "toggle"
          ];
        };

        "Super+Alt+S" = {
          allow-when-locked = true;
          hotkey-overlay.hidden = true;
          action.spawn-sh = "pkill orca || exec orca";
        };

        #
        # Audio
        #
        "XF86AudioRaiseVolume" = {
          allow-when-locked = true;
          action.spawn = [
            "wpctl"
            "set-volume"
            "@DEFAULT_AUDIO_SINK@"
            "0.1+"
            "-l"
            "1.0"
          ];
        };

        "XF86AudioLowerVolume" = {
          allow-when-locked = true;
          action.spawn = [
            "wpctl"
            "set-volume"
            "@DEFAULT_AUDIO_SINK@"
            "0.1-"
          ];
        };

        "XF86AudioMute" = {
          allow-when-locked = true;
          action.spawn = [
            "wpctl"
            "set-mute"
            "@DEFAULT_AUDIO_SINK@"
            "toggle"
          ];
        };

        "XF86AudioMicMute" = {
          allow-when-locked = true;
          action.spawn = [
            "wpctl"
            "set-mute"
            "@DEFAULT_AUDIO_SOURCE@"
            "toggle"
          ];
        };

        #
        # Media
        #
        "XF86AudioPlay" = {
          allow-when-locked = true;
          action.spawn = [ "playerctl" "play-pause" ];
        };

        "XF86AudioStop" = {
          allow-when-locked = true;
          action.spawn = [ "playerctl" "stop" ];
        };

        "XF86AudioPrev" = {
          allow-when-locked = true;
          action.spawn = [ "playerctl" "previous" ];
        };

        "XF86AudioNext" = {
          allow-when-locked = true;
          action.spawn = [ "playerctl" "next" ];
        };

        #
        # Brightness via DMS
        #
        "XF86MonBrightnessUp" = {
          allow-when-locked = true;
          action.spawn = [
            "dms"
            "ipc"
            "call"
            "brightness"
            "increment"
            "10"
          ];
        };

        "XF86MonBrightnessDown" = {
          allow-when-locked = true;
          action.spawn = [
            "dms"
            "ipc"
            "call"
            "brightness"
            "decrement"
            "10"
          ];
        };

        #
        # Overview / close
        #
        "Mod+O" = {
          repeat = false;
          action.toggle-overview = [ ];
        };

        "Mod+Q" = {
          repeat = false;
          action.close-window = [ ];
        };

        #
        # Focus
        #
        "Mod+Left".action.focus-column-left = [ ];
        "Mod+Down".action.focus-window-down = [ ];
        "Mod+Up".action.focus-window-up = [ ];
        "Mod+Right".action.focus-column-right = [ ];

        "Mod+H".action.focus-column-left = [ ];
        "Mod+J".action.focus-window-down = [ ];
        "Mod+K".action.focus-window-up = [ ];
        "Mod+L".action.focus-column-right = [ ];

        #
        # Move windows / columns
        #
        "Mod+Ctrl+Left".action.move-column-left = [ ];
        "Mod+Ctrl+Down".action.move-window-down = [ ];
        "Mod+Ctrl+Up".action.move-window-up = [ ];
        "Mod+Ctrl+Right".action.move-column-right = [ ];

        "Mod+Ctrl+H".action.move-column-left = [ ];
        "Mod+Ctrl+J".action.move-window-down = [ ];
        "Mod+Ctrl+K".action.move-window-up = [ ];
        "Mod+Ctrl+L".action.move-column-right = [ ];

        #
        # First / last column
        #
        "Mod+Home".action.focus-column-first = [ ];
        "Mod+End".action.focus-column-last = [ ];

        "Mod+Ctrl+Home".action.move-column-to-first = [ ];
        "Mod+Ctrl+End".action.move-column-to-last = [ ];

        #
        # Monitors
        #
        "Mod+Shift+Left".action.focus-monitor-left = [ ];
        "Mod+Shift+Down".action.focus-monitor-down = [ ];
        "Mod+Shift+Up".action.focus-monitor-up = [ ];
        "Mod+Shift+Right".action.focus-monitor-right = [ ];

        "Mod+Shift+H".action.focus-monitor-left = [ ];
        "Mod+Shift+J".action.focus-monitor-down = [ ];
        "Mod+Shift+K".action.focus-monitor-up = [ ];
        "Mod+Shift+L".action.focus-monitor-right = [ ];

        "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = [ ];
        "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = [ ];
        "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = [ ];
        "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = [ ];

        "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = [ ];
        "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = [ ];
        "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = [ ];
        "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = [ ];

        #
        # Workspaces
        #
        "Mod+Page_Down".action.focus-workspace-down = [ ];
        "Mod+Page_Up".action.focus-workspace-up = [ ];
        "Mod+U".action.focus-workspace-down = [ ];
        "Mod+I".action.focus-workspace-up = [ ];

        "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = [ ];
        "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = [ ];
        "Mod+Ctrl+U".action.move-column-to-workspace-down = [ ];
        "Mod+Ctrl+I".action.move-column-to-workspace-up = [ ];

        "Mod+Shift+Page_Down".action.move-workspace-down = [ ];
        "Mod+Shift+Page_Up".action.move-workspace-up = [ ];
        "Mod+Shift+U".action.move-workspace-down = [ ];
        "Mod+Shift+I".action.move-workspace-up = [ ];

        #
        # Mouse-wheel workspace navigation
        #
        "Mod+WheelScrollDown" = {
          cooldown-ms = 150;
          action.focus-workspace-down = [ ];
        };

        "Mod+WheelScrollUp" = {
          cooldown-ms = 150;
          action.focus-workspace-up = [ ];
        };

        "Mod+Ctrl+WheelScrollDown" = {
          cooldown-ms = 150;
          action.move-column-to-workspace-down = [ ];
        };

        "Mod+Ctrl+WheelScrollUp" = {
          cooldown-ms = 150;
          action.move-column-to-workspace-up = [ ];
        };

        "Mod+WheelScrollRight".action.focus-column-right = [ ];
        "Mod+WheelScrollLeft".action.focus-column-left = [ ];

        "Mod+Ctrl+WheelScrollRight".action.move-column-right = [ ];
        "Mod+Ctrl+WheelScrollLeft".action.move-column-left = [ ];

        "Mod+Shift+WheelScrollDown".action.focus-column-right = [ ];
        "Mod+Shift+WheelScrollUp".action.focus-column-left = [ ];

        "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-right = [ ];
        "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-left = [ ];

        #
        # Numbered workspaces
        #
        "Mod+1".action.focus-workspace = 1;
        "Mod+2".action.focus-workspace = 2;
        "Mod+3".action.focus-workspace = 3;
        "Mod+4".action.focus-workspace = 4;
        "Mod+5".action.focus-workspace = 5;
        "Mod+6".action.focus-workspace = 6;
        "Mod+7".action.focus-workspace = 7;
        "Mod+8".action.focus-workspace = 8;
        "Mod+9".action.focus-workspace = 9;

        "Mod+Ctrl+1".action.move-column-to-workspace = 1;
        "Mod+Ctrl+2".action.move-column-to-workspace = 2;
        "Mod+Ctrl+3".action.move-column-to-workspace = 3;
        "Mod+Ctrl+4".action.move-column-to-workspace = 4;
        "Mod+Ctrl+5".action.move-column-to-workspace = 5;
        "Mod+Ctrl+6".action.move-column-to-workspace = 6;
        "Mod+Ctrl+7".action.move-column-to-workspace = 7;
        "Mod+Ctrl+8".action.move-column-to-workspace = 8;
        "Mod+Ctrl+9".action.move-column-to-workspace = 9;

        #
        # Columns
        #
        "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
        "Mod+BracketRight".action.consume-or-expel-window-right = [ ];

        "Mod+Comma".action.consume-window-into-column = [ ];
        "Mod+Period".action.expel-window-from-column = [ ];

        #
        # Size
        #
        "Mod+R".action.switch-preset-column-width = [ ];
        "Mod+Shift+R".action.switch-preset-column-width-back = [ ];

        "Mod+Ctrl+Shift+R".action.switch-preset-window-height = [ ];
        "Mod+Ctrl+R".action.reset-window-height = [ ];

        "Mod+F".action.maximize-column = [ ];
        "Mod+Shift+F".action.fullscreen-window = [ ];

        "Mod+M".action.maximize-window-to-edges = [ ];
        "Mod+Ctrl+F".action.expand-column-to-available-width = [ ];

        "Mod+C".action.center-column = [ ];
        "Mod+Ctrl+C".action.center-visible-columns = [ ];

        "Mod+Minus".action.set-column-width = "-10%";
        "Mod+Equal".action.set-column-width = "+10%";

        "Mod+Shift+Minus".action.set-window-height = "-10%";
        "Mod+Shift+Equal".action.set-window-height = "+10%";

        #
        # Floating / tabbed
        #
        "Mod+V".action.toggle-window-floating = [ ];

        "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = [ ];

        "Mod+W".action.toggle-column-tabbed-display = [ ];

        #
        # Screenshots
        #
        "Print".action.screenshot = [ ];
        "Ctrl+Print".action.screenshot-screen = [ ];
        "Alt+Print".action.screenshot-window = [ ];

        #
        # Shortcut inhibition
        #
        "Mod+Escape" = {
          allow-inhibiting = false;
          action.toggle-keyboard-shortcuts-inhibit = [ ];
        };

        #
        # DMS power menu / exit
        #
        "Mod+Shift+E" = {
          hotkey-overlay.title = "Power Menu: DMS";

          action.spawn = [
            "dms"
            "ipc"
            "call"
            "powermenu"
            "toggle"
          ];
        };

        "Ctrl+Alt+Delete".action.quit = [ ];

        "Mod+Shift+P".action.power-off-monitors = [ ];
      };
    };
  };

  programs.home-manager.enable = true;
}
