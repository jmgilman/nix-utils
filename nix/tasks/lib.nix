{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs std;
  l = nixpkgs.lib // builtins;
in {
  mkTask = {
    name,
    text,
    category ? "",
    help ? "",
    runtimeInputs ? [],
  }:
    l.writeShellScriptApp {
      inherit name runtimeInputs text;
    }
    // {passthru = {inherit name category help;};};

  mkScriptTask = {
    name,
    path,
    category ? "",
    help ? "",
    runtimeInputs ? [],
    runtimeShell ? nixpkgs.runtimeShell,
  }:
    (nixpkgs.runCommand name
      {
        inherit path;
        meta.mainProgram = name;
      }
      ''
        mkdir -p $out/bin
        script="$out/bin/${name}"

        # Create initial script with correct shebang and inputs
        echo '#!${runtimeShell}' >$script
        echo 'export PATH="${l.makeBinPath runtimeInputs}:$PATH"' >>$script

        # Append the rest of the script with original shebang removed
        sed 's/^#!.*$//' $path | tail -n +2 >>$script
        chmod +x $script

        # Validate final result
        ${nixpkgs.stdenv.shellDryRun} $script
        ${nixpkgs.shellcheck}/bin/shellcheck $script
      '')
    // {passthru = {inherit name category help;};};

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
