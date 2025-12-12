{ firefox-addons }:

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.zen-flatpak;

  # Flatpak Zen profile directory
  zenProfileDir = "${config.home.homeDirectory}/.var/app/app.zen_browser.zen/.zen";

  # Generate a deterministic UUID from a name using SHA256
  # Creates a consistent UUID-like identifier for each pin
  generateUUID = name:
    let
      # Use sha256 hash of the name to generate a deterministic UUID
      hash = builtins.hashString "sha256" "zen-pin-${name}";
      # Format as UUID (take first 32 hex chars and format)
      part1 = builtins.substring 0 8 hash;
      part2 = builtins.substring 8 4 hash;
      part3 = builtins.substring 12 4 hash;
      part4 = builtins.substring 16 4 hash;
      part5 = builtins.substring 20 12 hash;
    in
      "${part1}-${part2}-${part3}-${part4}-${part5}";

  # Process pins and auto-generate UUIDs from names
  # First pass: add UUIDs and resolve folder parent references
  processedPinsPass1 = mapAttrs (name: pin:
    pin // {
      id = generateUUID name;
      # Convert folderParentUuid from name to UUID if specified
      folderParentUuidResolved =
        if pin.folderParentUuid != null
        then generateUUID pin.folderParentUuid
        else null;
    }
  ) cfg.pins;

  # Second pass: inherit workspace from parent folder and auto-assign positions
  processedPinsList = attrValues processedPinsPass1;
  processedPins = lib.lists.imap0 (index: pin:
    let
      # Find the parent folder if this pin is in a folder
      parentFolder = if pin.folderParentUuidResolved != null
        then builtins.head (builtins.filter
          (p: p.id == pin.folderParentUuidResolved)
          processedPinsList)
        else null;
      # Inherit workspace from parent if pin is in a folder and doesn't have its own workspace
      inheritedWorkspace = if parentFolder != null && pin.workspace == null
        then parentFolder.workspace
        else pin.workspace;
    in
    pin // {
      workspace = inheritedWorkspace;
      position = index + 1;  # Auto-assign position based on order in config
    }
  ) processedPinsList;

  # Generate user.js content from settings
  userJsContent = settings:
    concatStringsSep "\n" (
      mapAttrsToList (name: value:
        let
          valueStr = if isBool value then (if value then "true" else "false")
                     else if isInt value then toString value
                     else if isString value then ''"${value}"''
                     else toString value;
        in
        ''user_pref("${name}", ${valueStr});''
      ) settings
    );

in
{
  options.programs.zen-flatpak = {
    enable = mkEnableOption "Zen Browser Flatpak configuration";

    profile = mkOption {
      type = types.str;
      default = "default";
      description = "The name of the Zen profile to configure";
    };

    extensions = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "List of Firefox extensions to install (from firefox-addons)";
      example = literalExpression ''
        with firefox-addons.packages.x86_64-linux; [
          ublock-origin
          bitwarden
        ]
      '';
    };

    settings = mkOption {
      type = types.attrsOf (types.oneOf [ types.bool types.int types.str ]);
      default = {};
      description = "Firefox preferences to set in user.js";
      example = literalExpression ''
        {
          "browser.search.suggest.enabled" = false;
          "privacy.donottrackheader.enabled" = true;
        }
      '';
    };

    pinsForce = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to force-delete pins not declared in configuration";
    };

    pins = mkOption {
      type = types.attrsOf (types.submodule ({ name, ... }: {
        options = {
          url = mkOption {
            type = types.str;
            description = "URL of the pinned tab";
          };
          title = mkOption {
            type = types.str;
            default = name;
            description = "Title of the pinned tab";
          };
          isEssential = mkOption {
            type = types.bool;
            default = false;
            description = "Whether the tab is essential";
          };
          container = mkOption {
            type = types.nullOr types.int;
            default = null;
            description = "Container ID for the pinned tab";
          };
          workspace = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Workspace UUID for the pinned tab";
          };
          isGroup = mkOption {
            type = types.bool;
            default = false;
            description = "Whether this is a folder/group of pins";
          };
          folderParentUuid = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Parent folder name (pin name) for this pin";
          };
        };
      }));
      default = {};
      description = "Pinned tabs configuration (UUIDs and positions auto-generated from pin names and order)";
      example = literalExpression ''
        {
          "GitHub" = {
            url = "https://github.com";
            isEssential = true;
          };
          "Example" = {
            url = "https://example.com";
            isEssential = false;
          };
        }
      '';
    };

    policies = mkOption {
      type = types.attrs;
      default = {};
      description = "Firefox policies to apply";
      example = literalExpression ''
        {
          ExtensionSettings = {
            "uBlock0@raymondhill.net" = {
              installation_mode = "force_installed";
              toolbar_pin = "on";
            };
          };
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    home.activation.setupZenFlatpak = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Find the actual profile directory (usually *.default-release or similar)
      ZEN_PROFILE_ROOT="${zenProfileDir}"

      if [ ! -d "$ZEN_PROFILE_ROOT" ]; then
        $DRY_RUN_CMD echo "Warning: Zen Flatpak profile directory not found at $ZEN_PROFILE_ROOT"
        $DRY_RUN_CMD echo "Please run Zen Browser at least once to create the profile"
        exit 0
      fi

      # Find the default profile directory
      PROFILE_DIR=$(find "$ZEN_PROFILE_ROOT" -maxdepth 1 -type d -name "*.${cfg.profile}*" | head -n 1)

      if [ -z "$PROFILE_DIR" ]; then
        $DRY_RUN_CMD echo "Warning: Could not find profile matching '${cfg.profile}'"
        $DRY_RUN_CMD echo "Available profiles:"
        $DRY_RUN_CMD ls -1 "$ZEN_PROFILE_ROOT"
        exit 0
      fi

      $DRY_RUN_CMD echo "Configuring Zen Browser profile at: $PROFILE_DIR"

      # Install extensions
      ${optionalString (cfg.extensions != []) ''
        EXTENSIONS_DIR="$PROFILE_DIR/extensions"
        $DRY_RUN_CMD mkdir -p "$EXTENSIONS_DIR"

        ${concatMapStringsSep "\n" (addon: ''
          ADDON_ID="${addon.addonId or (builtins.baseNameOf addon)}"
          ADDON_XPI="${addon}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/$ADDON_ID.xpi"

          if [ -f "$ADDON_XPI" ]; then
            $DRY_RUN_CMD echo "Installing extension: $ADDON_ID"
            $DRY_RUN_CMD cp -f "$ADDON_XPI" "$EXTENSIONS_DIR/$ADDON_ID.xpi"
          else
            $DRY_RUN_CMD echo "Warning: Extension XPI not found at $ADDON_XPI"
          fi
        '') cfg.extensions}
      ''}

      # Write user.js settings
      ${optionalString (cfg.settings != {}) ''
        USER_JS="$PROFILE_DIR/user.js"
        $DRY_RUN_CMD echo "Writing settings to user.js"

        cat > "$USER_JS" << 'EOF'
// Generated by Nix - Do not edit manually
${userJsContent cfg.settings}
EOF
      ''}

      # Write policies.json
      ${optionalString (cfg.policies != {}) ''
        POLICIES_DIR="${config.home.homeDirectory}/.var/app/app.zen_browser.zen/.zen/policies"
        $DRY_RUN_CMD mkdir -p "$POLICIES_DIR"

        cat > "$POLICIES_DIR/policies.json" << 'EOF'
${builtins.toJSON { policies = cfg.policies; }}
EOF
        $DRY_RUN_CMD echo "Wrote policies to $POLICIES_DIR/policies.json"
      ''}

      # Setup pinned tabs via SQLite database
      ${optionalString (cfg.pins != {}) ''
        PLACES_DB="$PROFILE_DIR/places.sqlite"

        if [ ! -f "$PLACES_DB" ]; then
          $DRY_RUN_CMD echo "Warning: places.sqlite not found, skipping pin setup"
        else
          $DRY_RUN_CMD echo "Setting up pinned tabs in places.sqlite"

          # Create zen_pins table if it doesn't exist
          ${pkgs.sqlite}/bin/sqlite3 "$PLACES_DB" << 'EOSQL'
CREATE TABLE IF NOT EXISTS zen_pins (
  uuid TEXT PRIMARY KEY,
  title TEXT,
  url TEXT,
  container_id INTEGER,
  workspace_uuid TEXT,
  position INTEGER,
  is_essential INTEGER,
  is_group INTEGER,
  created_at INTEGER,
  updated_at INTEGER,
  edited_title INTEGER,
  is_folder_collapsed INTEGER,
  folder_icon TEXT,
  folder_parent_uuid TEXT
);
EOSQL

          # Force delete pins not in config if pinsForce is enabled
          ${optionalString cfg.pinsForce ''
            $DRY_RUN_CMD echo "Force-deleting pins not in configuration"
            ${pkgs.sqlite}/bin/sqlite3 "$PLACES_DB" << 'EOSQL'
DELETE FROM zen_pins WHERE uuid NOT IN (
  ${concatStringsSep ",\n  " (map (pin: "'${pin.id}'") processedPins)}
);
EOSQL
          ''}

          # Insert or update all pins in a single transaction
          ${pkgs.sqlite}/bin/sqlite3 "$PLACES_DB" << 'EOSQL'
BEGIN TRANSACTION;
${concatMapStringsSep "\n" (pin: ''
INSERT OR REPLACE INTO zen_pins (
  uuid, title, url, container_id, workspace_uuid, position,
  is_essential, is_group, created_at, updated_at,
  edited_title, is_folder_collapsed, folder_icon, folder_parent_uuid
) VALUES (
  '${pin.id}',
  '${pin.title}',
  '${pin.url}',
  ${if pin.container != null then toString pin.container else "NULL"},
  ${if pin.workspace != null then "'${pin.workspace}'" else "NULL"},
  ${toString pin.position},
  ${if pin.isEssential then "1" else "0"},
  ${if pin.isGroup then "1" else "0"},
  strftime('%s', 'now'),
  strftime('%s', 'now'),
  0,
  0,
  NULL,
  ${if pin.folderParentUuidResolved != null then "'${pin.folderParentUuidResolved}'" else "NULL"}
);'') processedPins}
COMMIT;
EOSQL
          $DRY_RUN_CMD echo "Configured ${toString (length processedPins)} pinned tab(s)"

          $DRY_RUN_CMD echo "Pinned tabs configured successfully"
        fi
      ''}

      $DRY_RUN_CMD echo "Zen Browser Flatpak configuration complete"
    '';
  };
}
