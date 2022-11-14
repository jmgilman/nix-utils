{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs std;
  l = nixpkgs.lib // builtins;
in {
  logging = cell.lib.writeNuInclude {
    name = "logging";
    script = inputs.self + "/nix/nu/includes/logging.nu";
  };
}
