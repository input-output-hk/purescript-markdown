{
  description = "A Purescript library for parsing SlamData's dialect of Markdown";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    easy-ps = {
      url = "github:justinwoo/easy-purescript-nix";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, easy-ps }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ]
      ( system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
          {
            devShell = pkgs.mkShell {
              buildInputs = with import easy-ps { inherit pkgs; }; [
                purs
                spago
                purty
                purescript-language-server
              ];
            };
          }
      );
}
