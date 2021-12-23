{ stdenv }:
let
  configRepo = builtins.fetchGit {
    url = "https://Chris2011@github.com/Chris2011/nix-configurations.git";
    ref = "master";
  };
in
  stdenv.mkDerivation {
    name = "hello.txt";
    unpackPhase = "true";

    installPhase = ''
    echo -n "Hello World!" > $out

    ls -ahl ${configRepo}
    echo "${configRepo}"
    '';
  }
