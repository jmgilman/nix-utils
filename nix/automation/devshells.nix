{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs std;
  inherit (inputs.cells.devshell) profiles;
  l = nixpkgs.lib // builtins;
in
  l.mapAttrs (_: std.lib.dev.mkShell) {
    default = {...}: {
      name = "nix-utils devshell";
      imports = [
        (profiles.core {})
        (profiles.format {})
      ];
    };
  }
