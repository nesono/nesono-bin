{ config, pkgs, ... }:

{
  # Required for Obsidian
  nixpkgs.config.allowUnfree = true;

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "ji";
  home.homeDirectory = "/home/ji";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "26.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
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

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    # Expose Nix-installed wallpapers in a normal user directory so desktop
    # background pickers can discover them.
    "Pictures/Wallpapers/nixos".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.profileDirectory}/share/backgrounds/nixos";
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/ji/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
	NESONOBININSTALLATIONDIR = "${config.home.homeDirectory}/nesono-bin";
	EDITOR = "nvim";
  };

  home.sessionPath = [
    "/home/ji/.opencode/bin"
  ];

  # Remap Caps Lock to Ctrl.
  # NOTE: this only covers GNOME/Wayland sessions. The niri session reads its
  # own xkb config, so the same "ctrl:nocaps" option is set in
  # niri/config.kdl (input.keyboard.xkb.options). Keep both in sync.
  dconf.enable = true;
  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      xkb-options = [ "ctrl:nocaps" ];
    };
  };

  programs = {
    zsh = {
      enable = true;

      initContent = ''
        . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
        . "$HOME/nesono-bin/zshrc"
      '';
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    starship.enable = true;

    zellij = {
      enable = true;
      # Auto-starting zellij in every shell is surprising; opt in if wanted.
      enableZshIntegration = false;
    };
  };
  programs.dank-material-shell.enable = true;
  programs.fuzzel.enable = true;

  xdg.configFile."niri/config.kdl".source = ./niri/config.kdl;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
