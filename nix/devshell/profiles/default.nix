{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs std;
  l = nixpkgs.lib // builtins;
in {
  core = import ./core.nix {inherit inputs cell;};
  format = import ./format.nix {inherit inputs cell;};
}
