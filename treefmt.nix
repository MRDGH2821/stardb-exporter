{
  projectRootFile = "flake.nix";
  # keep-sorted start
  programs.actionlint.enable = true;
  programs.alejandra.enable = true;
  programs.deadnix.enable = true;
  # programs.dprint.enable = true;
  programs.flake-edit.enable = true;
  programs.keep-sorted.enable = true;
  programs.nixf-diagnose.enable = true;
  programs.nixfmt.enable = true;
  programs.nixpkgs-fmt.enable = true;
  programs.pinact.enable = true;
  programs.prettier.enable = true;
  programs.rustfmt.enable = true;
  programs.statix.enable = true;
  programs.taplo.enable = true;
  programs.toml-sort.enable = true;
  programs.yamlfmt.enable = true;
  programs.yamllint.enable = true;
  programs.zizmor.enable = true;
  # keep-sorted end

  settings.formatter = {
    alejandra.priority = 10;
  };
}
