{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs std;
  l = nixpkgs.lib // builtins;
in {
  writeShellScript = {
    name,
    script,
    runtimeInputs ? [],
    runtimeShell ? nixpkgs.runtimeShell,
  }:
    nixpkgs.runCommand name
    {
      inherit script;
      meta.mainProgram = name;
    }
    ''
      mkdir -p $out/bin
      file="$out/bin/${name}"

      # Check if we were given a path or a string
      if [[ ! -f "''${script}" ]]; then
        echo -n "''${script}" >script.sh
        script="./script.sh"
      fi

      # Create initial script with correct shebang and inputs
      echo '#!${runtimeShell}' >$file
      echo 'export PATH="${l.makeBinPath runtimeInputs}:$PATH"' >>$file

      # Remove shebang if present
      if cat $script | head -n1 | grep '#!'; then
        cat $script | tail -n+2 >>$file
      else
        cat $script >>$file
      fi

      chmod +x $file

      # Validate final result
      ${nixpkgs.stdenv.shellDryRun} $file
      ${nixpkgs.shellcheck}/bin/shellcheck $file
    '';
}
