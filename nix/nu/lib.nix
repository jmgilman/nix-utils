{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs std;
  l = nixpkgs.lib // builtins;
in {
  writeNuInclude = {
    name,
    script,
  }:
    nixpkgs.runCommand name
    {
      inherit script;
    }
    ''
      # Check if we were given a path or a string
      if [[ ! -f "''${script}" ]]; then
        echo -n "''${script}" >$out
      else
        cp $script $out
      fi
    '';
  writeNuScript = {
    name,
    script,
    includes ? [],
    runtimeInputs ? [],
    nushell ? cell.packages.nushell,
  }: let
    mkBinPath = path: ''
      let-env PATH = ($env.PATH | prepend ${path}/bin)
    '';
    mkInclude = path: ''
      source ${path}
    '';
    paths = l.concatStringsSep "\n" (l.map (p: mkBinPath p) runtimeInputs);
    includes' = l.concatStringsSep "\n" (l.map (p: mkInclude p) includes);
  in
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
        echo -n "''${script}" >script.nu
        script="./script.nu"
      fi

      # Create initial script with correct shebang and inputs
      echo '#!${nushell}/bin/nu' >$file
      echo '${includes'}' >>$file
      echo '${paths}' >>$file

      # Remove shebang if present
      if cat $script | head -n1 | grep '#!'; then
        cat $script | tail -n+2 >>$file
      else
        cat $script >>$file
      fi

      # Run sanity check
      cp $file tmp.nu
      set +e
      if ! ${nushell}/bin/nu -c "if nu-check tmp.nu { exit 0 } else { exit 1 }"; then
        ${nushell}/bin/nu tmp.nu
        echo "The nushell script contains syntax errors. Please validate and try again."
        exit 1
      fi
      set -e

      chmod +x $file
    '';
}
