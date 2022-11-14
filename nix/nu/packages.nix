{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs std;
  l = nixpkgs.lib // builtins;
in {
  nushell = with nixpkgs;
    rustPlatform.buildRustPackage rec {
      pname = "nushell";
      version = "0.71.0";

      src = fetchFromGitHub {
        owner = pname;
        repo = pname;
        rev = version;
        sha256 = "sha256-81vyW5GovBnH3tLr77V2uLIkigymF+nOZ0F/J4eEu9Q=";
      };

      cargoSha256 = "sha256-hfL7cjqEH6SxZxIQA+QhSLMwCPC5MjSweuLEq1rHEa0=";

      nativeBuildInputs =
        [pkg-config]
        ++ lib.optionals (stdenv.isLinux) [python3];

      buildInputs =
        [openssl zstd]
        ++ lib.optionals stdenv.isDarwin [zlib libiconv Security]
        ++ lib.optionals (stdenv.isLinux) [xorg.libX11]
        ++ lib.optionals (stdenv.isDarwin) [AppKit nghttp2 libgit2];

      buildFeatures = "extra";

      doCheck = false;

      checkPhase = ''
        runHook preCheck
        echo "Running cargo test"
        HOME=$TMPDIR cargo test
        runHook postCheck
      '';

      meta = with lib; {
        description = "A modern shell written in Rust";
        homepage = "https://www.nushell.sh/";
        license = licenses.mit;
        maintainers = with maintainers; [Br1ght0ne johntitor marsam];
        mainProgram = "nu";
      };

      passthru = {
        shellPath = "/bin/nu";
      };
    };
}
