{
  description = "A Purescript library for parsing SlamData's dialect of Markdown";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    easy-purescript-nix-source = {
      url = "github:justinwoo/easy-purescript-nix";
      flake = false;
    };
    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, easy-purescript-nix-source, gitignore }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ]
      ( system:
        let
          pkgs = import nixpkgs { inherit system; };
          inherit (gitignore.lib) gitignoreSource;
          spagoPkgs = import ./spago-packages.nix { inherit pkgs; };
          easy-ps = import easy-purescript-nix-source { inherit pkgs; };
          purescriptMarkdown =
            pkgs.stdenv.mkDerivation {
              name = "purescript-markdown";
              buildInputs = [
                spagoPkgs.installSpagoStyle
                spagoPkgs.buildSpagoStyle
              ];
              nativeBuildInputs = with easy-ps; [
                psa
                purs
                spago
              ];
              src = gitignoreSource ./.;
              unpackPhase = ''
                cp $src/spago.dhall .
                cp $src/packages.dhall .
                cp -r $src/src .
                install-spago-style
                '';
              buildPhase = ''
                build-spago-style "./src/**/*.purs"
                '';
              installPhase = ''
                mkdir $out
                mv output $out/
                '';
            };
          clean = pkgs.writeShellScriptBin "clean" ''
            set -e
            echo cleaning project...
            rm -rf .spago .spago2nix output
            echo removed .spago
            echo removed .spago2nix
            echo removed output
            echo done.
            '';
        in
          {
            packages = { inherit purescriptMarkdown; };
            defaultPackage = purescriptMarkdown;
            devShell = pkgs.mkShell {
              buildInputs = with easy-ps; [
                clean
                psa
                purescript-language-server
                purs
                purs-tidy
                spago
                spago2nix
              ];
            };
          }
      );
}
