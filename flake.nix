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
      in {
        formatter = treefmtEval.config.build.wrapper;
        checks.formatting = treefmtEval.config.build.check self;
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
