{
  inputs = {
    # keep-sorted start
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    rust-overlay.url = "github:oxalica/rust-overlay";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    # keep-sorted end
  };

  outputs = {
    # keep-sorted start
    flake-utils,
    nixpkgs,
    rust-overlay,
    self,
    treefmt-nix,
    # keep-sorted end
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        overlays = [(import rust-overlay)];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        cargoToml = builtins.fromTOML (builtins.readFile ./Cargo.toml);
      in {
        formatter = treefmtEval.config.build.wrapper;
        checks.formatting = treefmtEval.config.build.check self;
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = cargoToml.package.name;
          version = cargoToml.package.version;

          src = pkgs.lib.cleanSource ./.;

          cargoLock = {
            lockFile = ./Cargo.lock;
            outputHashes = {
              "auto-artifactarium-1.2.2" = "sha256-r0yy9T8XvZWRtH/1OczSclw5MX2nFQkwB5jehuRxFS0=";
              "auto-reliquary-1.2.0" = "sha256-OLAFPCqXAUl7k4h73sUykBNj5J9kQ8HboMjAjmJQtu8=";
              "kcp-0.6.0" = "sha256-YzG8Ay+FquV3jwbdfh3bZQO3UYgM7iv8K0RtagYaS2o=";
            };
          };

          buildFeatures = ["pcap"];

          nativeBuildInputs = [pkgs.pkg-config];
          buildInputs = [pkgs.openssl pkgs.libpcap];

          meta = {
            description = "Export HSR/Genshin data via packet capture";
            homepage = "https://github.com/juliuskreutz/stardb-exporter";
            license = pkgs.lib.licenses.mit;
            mainProgram = "stardb-exporter";
          };
        };
        devShells.default = with pkgs;
          mkShell {
            buildInputs = [
              # keep-sorted start
              libpcap
              openssl
              pkg-config
              rust-analyzer
              rust-bin.stable.latest.default
              taplo
              # keep-sorted end
            ];

            WINIT_UNIX_BACKEND = "wayland";
            # Nix's libGL/EGL is just a vendor-neutral dispatcher; it needs the
            # host's real driver to actually initialize a display. On NixOS that's
            # /run/opengl-driver, on other distros it's usually /usr/lib64 or /usr/lib.
            LD_LIBRARY_PATH = "${
              lib.makeLibraryPath [
                wayland
                libxkbcommon
                libGL
              ]
            }:/run/opengl-driver/lib:/usr/lib64:/usr/lib";
          };
      }
    );
}
