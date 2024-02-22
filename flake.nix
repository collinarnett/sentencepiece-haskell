{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
  outputs = inputs @ {
    nixpkgs,
    flake-parts,
    self,
  }:
    flake-parts.lib.mkFlake {
      inherit inputs;
    } {
      systems = ["x86_64-linux"];
      perSystem = {
        system,
        pkgs,
        lib,
        ...
      }: {
        packages.default = pkgs.haskellPackages.callCabal2nix "sentencepiece-haskell" ./. {};
        devShells.default = pkgs.haskellPackages.shellFor {
          packages = ps: [
            (ps.callCabal2nix "sentencepiece-haskell" ./. {})
          ];
          buildInputs = with pkgs; [
            cabal-install
            stylish-haskell
            sentencepiece
          ];
          LD_LIBRARY_PATH = lib.makeLibraryPath [pkgs.sentencepiece];
          withHoogle = true;
        };
      };
    };
}
