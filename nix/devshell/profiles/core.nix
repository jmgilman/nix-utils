{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs std;
  l = nixpkgs.lib // builtins;
in
  {
    types ? [],
    scopes ? [],
    hooks ? {},
  }: let
    conform = std.lib.cfg.conform {
      data = {
        commit = {
          header = {length = 89;};
          conventional = {
            inherit scopes;
            types =
              [
                "build"
                "chore"
                "ci"
                "docs"
                "feat"
                "fix"
                "perf"
                "refactor"
                "style"
                "test"
              ]
              ++ types;
          };
        };
      };
    };
    lefthook = std.lib.cfg.lefthook {
      data = {
        commit-msg = {
          commands = {
            conform = {
              run = "${nixpkgs.conform}/bin/conform enforce --commit-msg-file {1}";
            };
          };
        };
        pre-commit = {
          commands =
            {
              treefmt = {
                run = "${nixpkgs.treefmt}/bin/treefmt {staged_files}";
              };
            }
            // hooks;
        };
      };
    };
  in
    {...}: {
      nixago = [
        conform
        lefthook
      ];
    }
