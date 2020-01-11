{ nixpkgs ? import ./.nix/nixpkgs.nix
, compiler ? "default"
, doBenchmark ? false
}:
let
  pkgs = import nixpkgs {};

  haskellPackages = if compiler == "default"
    then pkgs.haskellPackages
    else pkgs.haskell.packages.${compiler};

  hask = haskellPackages.override {
    overrides = hself: hsuper: with pkgs.haskell.lib; {
      hsc2hs = hsuper.callHackage "hsc2hs" "0.68.6" {};
      clang-pure = overrideCabal (hsuper.callPackage ./clang-pure.nix {}) (_: { inherit doBenchmark; });
    };
  };

in
  hask.shellFor {
    buildInputs = [
      hask.ghc
      hask.cabal-install
      pkgs.llvm
    ];
    packages = p: [ p.clang-pure ];
  }
