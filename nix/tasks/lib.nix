{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs std;
  inherit (inputs.cells) shell;
  l = nixpkgs.lib // builtins;
in {
  mkTask = {
    script,
    name,
    category ? "",
    help ? "",
  }:
    script // {passthru = {inherit name category help;};};

  mkTaskCommand = {
    task,
    cell ? "automation",
    cellBlock ? "tasks",
  }: {
    inherit (task.passthru) name help category;
    command = ''
      nix run .#${nixpkgs.system}.${cell}.${cellBlock}.${task.name}
    '';
  };
}
