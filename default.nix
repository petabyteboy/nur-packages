# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ sources ? import ./nix/sources.nix
, nixpkgs ? sources.nixpkgs
, pkgs ? import nixpkgs {}
, nixTestRunnerSrc ? sources.nix-test-runner
, nixTestRunner ? pkgs.callPackage nixTestRunnerSrc {}
, crate2nixSrc ? sources.crate2nix
}:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = pkgs.callPackage ./lib { inherit nixTestRunner; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # Integration tests.
  tests = pkgs.lib.callPackageWith
    (pkgs // { inherit sources; nurKollochLib = lib; } )
    ./tests {};

  # Packages.
  nix-test-runner = nixTestRunner.package.overrideAttrs(attrs: {
    # Uses import from derivation which NUR does not support.
    meta.broken = true;
  });
  crate2nix = (pkgs.callPackage crate2nixSrc {}).overrideAttrs(attrs: {
    # Uses import from derivation which NUR does not support.
    meta.broken = true;
  });
}

