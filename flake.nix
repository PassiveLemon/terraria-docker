{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs = { ... } @ inputs:
  inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" ];

    perSystem = { self', system, ... }:
    let
      pkgs = import inputs.nixpkgs { inherit system; };
      lib = pkgs.lib;
    in
    {
      devShells = {
        default = pkgs.mkShell {
          packages = with pkgs; [
            act dive trivy
          ];
          shellHook = ''
            alias nr="nix run .#"
          '';
        };
      };
      packages = let
        build = lib.getExe self'.packages.build;
        tVersion = "1.4.5.8";
        tmlVersion = "2026.08.3.0";
      in {
        default = self'.packages.test;
        build = pkgs.writeShellApplication {
          name = "build";
          runtimeInputs = with pkgs; [ docker ];
          text = ''
            docker build ${./.} -t test-terraria \
              --build-arg VANILLA="true" \
              --build-arg VERSION="${tVersion}"

            docker build ${./.} -t test-tmodloader \
              --build-arg VANILLA="false" \
              --build-arg VERSION="${tmlVersion}"
          '';
        };
        test = pkgs.writeShellApplication {
          name = "test-container";
          runtimeInputs = with pkgs; [ docker ];
          text = ''
            ${build}
            docker compose up "test-$1"
          '';
        };
        trivy = pkgs.writeShellApplication {
          name = "trivy-image";
          runtimeInputs = with pkgs; [ trivy ];
          text = ''
            ${build}
            trivy image "test-$1"
          '';
        };
      };
    };
  };
}

