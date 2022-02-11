{
  description = "Mobile application for taking books pictures";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    android.url = "github:tadfisher/android-nixpkgs";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, android, ... }:
    let
      system = "x86_64-linux";
      name = (builtins.fromJSON (builtins.readFile ./package.json)).name;
      pkgs = import nixpkgs { inherit system; };
    in
    rec {
      packages.${system} = {
        android-sdk = android.sdk.${system} (sdkPkgs: with sdkPkgs; [
          emulator
          platform-tools
          cmdline-tools-latest
          build-tools-30-0-2
          platforms-android-31
          system-images-android-31-google-apis-x86-64
        ]);
      };

      # nix develop
      devShell.${system} =
        let
          aapt2 = import (builtins.toPath "${android}/pkgs/aapt2") {
            inherit (pkgs) stdenv lib fetchurl autoPatchelfHook patchelf unzip;
          };
          packages = with pkgs; [ ripgrep rnix-lsp nixpkgs-fmt yarn nodejs ];
          androidPackages = with pkgs; [
            jdk11
            gradle
            aapt2
            self.packages.${system}.android-sdk
          ];
          nodePackages = with pkgs.nodePackages; [
            prettier
            typescript
            typescript-language-server
            vscode-json-languageserver
            vscode-css-languageserver-bin
          ];
        in
        pkgs.mkShell {
          buildInputs = packages ++ androidPackages ++ nodePackages;
          GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${aapt2}/bin/aapt2";
        };
    };
}
