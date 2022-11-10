{
  inputs.nixpkgs.url = "nixpkgs";

  inputs.std.url = "github:divnix/std";
  inputs.std.inputs.nixpkgs.follows = "nixpkgs";

  outputs = {std, ...} @ inputs:
    std.growOn
    {
      inherit inputs;
      cellsFrom = ./nix;

      cellBlocks = [
        (std.blockTypes.devshells "devshells")
        (std.blockTypes.functions "profiles")
        (std.blockTypes.nixago "configs")
      ];
    }
    {
      devshell = std.harvest inputs.self ["devshell"];
      devShells = std.harvest inputs.self ["automation" "devshells"];
    };
}
