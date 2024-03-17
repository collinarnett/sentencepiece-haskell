{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs @ {
    nixpkgs,
    flake-parts,
    treefmt-nix,
    self,
  }:
    flake-parts.lib.mkFlake {
      inherit inputs;
    } {
      imports = [inputs.treefmt-nix.flakeModule];
      systems = ["x86_64-linux"];
      flake.overlays.default = final-haskell: prev-haskell: {
        sentencepiece-haskell = final-haskell.callCabal2nix "sentencepiece-haskell" ./. {};
      };
      perSystem = {
        system,
        pkgs,
        config,
        lib,
        ...
      }: {
        treefmt.config = {
          projectRootFile = "flake.nix";
          programs.ormolu.enable = true;
          programs.alejandra.enable = true;
          programs.cabal-fmt.enable = true;
          programs.hlint.enable = true;
        };
        packages.default = pkgs.haskellPackages.callCabal2nix "sentencepiece-haskell" ./. {};
        devShells.default = pkgs.haskellPackages.shellFor {
          packages = ps: [
            (ps.callCabal2nix "sentencepiece-haskell" ./. {})
          ];
          inputsFrom = [
            config.treefmt.build.devShell
          ];
          buildInputs = with pkgs; [
            cabal-install
            sentencepiece
            haskell-language-server
          ];
          LD_LIBRARY_PATH = lib.makeLibraryPath [pkgs.sentencepiece];
          withHoogle = true;
        };
      };
    };
}
