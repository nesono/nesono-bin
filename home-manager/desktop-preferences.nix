{ lib, ... }:

let
  dmsSettings = ./preferences/dms-settings.json;
  ghosttyConfig = ./preferences/ghostty-config;
in
{
  # Capture the laptop's current preferences before managing these files.
  # Until a file is committed here, leave its existing home-directory copy alone.
  xdg.configFile =
    lib.optionalAttrs (builtins.pathExists dmsSettings) {
      "DankMaterialShell/settings.json".text =
        builtins.toJSON (builtins.fromJSON (builtins.readFile dmsSettings));
    }
    // lib.optionalAttrs (builtins.pathExists ghosttyConfig) {
      "ghostty/config".source = ghosttyConfig;
    };
}
