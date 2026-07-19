{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      rust-overlay,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
      in
      {
        devShells.default =
          with pkgs;
          mkShell {
            buildInputs = [
              rust-bin.stable.latest.default
              rust-analyzer
              taplo

              pkg-config
              openssl
              libpcap
            ];

            WINIT_UNIX_BACKEND = "wayland";
            # Nix's libGL/EGL is just a vendor-neutral dispatcher; it needs the
            # host's real driver to actually initialize a display. On NixOS that's
            # /run/opengl-driver, on other distros it's usually /usr/lib64 or /usr/lib.
            LD_LIBRARY_PATH = "${lib.makeLibraryPath [
              wayland
              libxkbcommon
              libGL
            ]}:/run/opengl-driver/lib:/usr/lib64:/usr/lib";
          };
      }
    );
}
