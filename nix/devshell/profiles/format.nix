{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs std;
  l = nixpkgs.lib // builtins;
in
  {
    formatters ? {},
    packages ? [],
  }: let
    prettier =
      std.lib.dev.mkNixago
      {
        configData = {
          printWidth = 80;
          proseWrap = "always";
        };
        output = ".prettierrc";
        format = "json";
        packages = [nixpkgs.nodePackages.prettier];
      };
    treefmt =
      std.std.nixago.treefmt
      {
        configData = {
          formatter =
            {
              nix = {
                command = "alejandra";
                includes = ["*.nix"];
              };
              prettier = {
                command = "prettier";
                options = ["--write"];
                includes = [
                  "*.md"
                ];
              };
            }
            // formatters;
        };
        packages = [nixpkgs.alejandra] ++ packages;
      };
  in
    {...}: {
      nixago = [
        prettier
        treefmt
      ];
    }
