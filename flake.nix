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
        tVersion = "1.4.5.5";
        tmlVersion = "2025.12.3.1";
        # lib.replaceString doesn't exist?
        tVersionTrim = lib.replaceStrings [ "." ] [ "" ] tVersion;
      in {
        default = self'.packages.test;
        build = pkgs.writeShellApplication {
          name = "build";
          runtimeInputs = with pkgs; [ docker ];
          text = ''
            docker build ${./terraria} -t test-terraria \
              --build-arg TVERSION=${tVersion} \
              --build-arg TVERSIONTRIM=${tVersionTrim}

            docker build ${./tmodloader} -t test-tmodloader \
              --build-arg TMLVERSION=${tmlVersion}
          '';
          meta.mainProgram = "build";
        };
        test = pkgs.writeShellApplication {
          name = "test-container";
          runtimeInputs = with pkgs; [ docker ];
          text = ''
            ${build}
            docker compose up
          '';
        };
        trivy = pkgs.writeShellApplication {
          name = "trivy-image";
          runtimeInputs = with pkgs; [ docker trivy ];
          # Need to supply the image name manually
          text = ''
            ${build}
            trivy image "$1"
          '';
        };
      };
    };
  };
}

