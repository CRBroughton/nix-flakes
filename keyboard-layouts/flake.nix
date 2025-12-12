{
  description = "Custom keyboard layouts for Linux with GNOME/KDE integration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    {
      homeManagerModules.default = { config, lib, pkgs, ... }:
        with lib;
        let
          cfg = config.programs.keyboard-layouts;
          inherit (lib.hm.gvariant) mkTuple;

          layoutType = types.submodule {
            options = {
              symbolsFile = mkOption {
                type = types.path;
                description = "Path to the XKB symbols file";
                example = "./layouts/graphite";
              };

              name = mkOption {
                type = types.str;
                description = "Internal name/ID for the layout (used in XKB)";
                example = "graphite";
              };

              description = mkOption {
                type = types.str;
                description = "Full description shown in desktop settings";
                example = "English (Graphite)";
              };

              shortDescription = mkOption {
                type = types.str;
                default = "";
                description = "Short description for the layout";
                example = "Graphite";
              };

              languages = mkOption {
                type = types.listOf types.str;
                default = [ "eng" ];
                description = "ISO 639 language codes";
                example = [ "eng" ];
              };
            };
          };

          # Generates evdev.xml content from layout definitions
          generateEvdevXml = layouts:
            let
              mkLayoutEntry = layout: ''
                    <layout>
                      <configItem>
                        <name>${layout.name}</name>
                        ${optionalString (layout.shortDescription != "") "<shortDescription>${layout.shortDescription}</shortDescription>"}
                        <description>${layout.description}</description>
                        ${optionalString (layout.languages != []) ''
                        <languageList>
                          ${concatStringsSep "\n          " (map (lang: "<iso639Id>${lang}</iso639Id>") layout.languages)}
                        </languageList>
                        ''}
                      </configItem>
                    </layout>
              '';
            in
            pkgs.writeText "evdev.xml" ''
              <?xml version="1.0" encoding="UTF-8"?>
              <!DOCTYPE xkbConfigRegistry SYSTEM "xkb.dtd">
              <xkbConfigRegistry version="1.1">
                <layoutList>
              ${concatStringsSep "\n" (map mkLayoutEntry layouts)}
                </layoutList>
              </xkbConfigRegistry>
            '';

          # Generates dconf tuples for custom layouts
          mkLayoutTuple = layout: mkTuple [ "xkb" layout.name ];
          customLayoutTuples = map mkLayoutTuple cfg.layouts;

          # Generates dconf tuples for standard layouts
          standardLayoutTuples = map (layout: mkTuple [ "xkb" layout ]) cfg.standardLayouts;

          evdevXmlFile = generateEvdevXml cfg.layouts;

        in
        {
          options.programs.keyboard-layouts = {
            enable = mkEnableOption "custom keyboard layouts";

            layouts = mkOption {
              type = types.listOf layoutType;
              default = [];
              description = ''
                List of custom keyboard layouts to install.
                Each layout should include:
                - symbolsFile: Path to the XKB symbols file
                - name: Internal identifier
                - description: Full description for desktop settings
                - shortDescription: (optional) Short name
                - languages: (optional) List of ISO 639 language codes
              '';
              example = literalExpression ''
                [
                  {
                    symbolsFile = ./layouts/graphite;
                    name = "graphite";
                    description = "English (Graphite)";
                    shortDescription = "Graphite";
                    languages = [ "eng" ];
                  }
                ]
              '';
            };

            standardLayouts = mkOption {
              type = types.listOf types.str;
              default = [ "us" ];
              description = ''
                Standard keyboard layouts to include (e.g., "us", "gb", "de").
                These will be added before the custom layouts in GNOME/KDE.
              '';
              example = [ "us" "gb" ];
            };

            xkbOptions = mkOption {
              type = types.listOf types.str;
              default = [ "terminate:ctrl_alt_bksp" ];
              description = ''
                XKB options to apply globally.
              '';
              example = [ "terminate:ctrl_alt_bksp" "caps:escape" ];
            };
          };

          config = mkIf cfg.enable {
            # Install XKB symbol files for each layout and evdev.xml rules file
            home.file = listToAttrs (
              map (layout: {
                name = ".config/xkb/symbols/${layout.name}";
                value = {
                  source = layout.symbolsFile;
                };
              }) cfg.layouts
            ) // {
              ".config/xkb/rules/evdev.xml".source = evdevXmlFile;
            };

            # Configure GNOME/KDE to recognise the layouts
            dconf.settings = {
              "org/gnome/desktop/input-sources" = {
                sources = standardLayoutTuples ++ customLayoutTuples;
                xkb-options = cfg.xkbOptions;
              };
            };

            # Helpful activation message
            home.activation.keyboardLayoutsInfo = lib.hm.dag.entryAfter ["writeBoundary"] ''
              echo "Custom keyboard layouts installed:"
              ${concatStringsSep "\n" (map (layout: "echo \"  - ${layout.description}\"") cfg.layouts)}
              echo ""
              echo "After activation, you may need to:"
              echo "  1. Log out and log back in"
              echo "  2. Open Desktop Settings → Keyboard → Input Sources"
              echo "  3. Select your preferred layout"
            '';
          };
        };
    };
}
