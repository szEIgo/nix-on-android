{ config, lib, pkgs, ... }: {

  imports = [
    ./zsh.nix
  ];

  home.packages = with pkgs; [
    git
    htop
    zsh-powerlevel10k
    oh-my-zsh
  ];
  programs.git.enable = true;
  programs.zellij = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        default_layout = "compact";
        default_shell = "zsh";
      };
    };

  programs.fzf.enable = true;

  programs.zoxide.enable = true;
  programs.zoxide.enableZshIntegration = true;
  programs.helix = {
    enable = true;
    settings = {
      theme = "autumn_night_transparent";
      editor.cursor-shape = {
        normal = "block";
        insert = "bar";
        select = "underline";
      };
    };
    languages.language = [{
      name = "nix";
      auto-format = true;
      formatter.command = "${pkgs.nixfmt-classic}/bin/nixfmt";
    }];
    themes = {
      autumn_night_transparent = {
        "inherits" = "autumn_night";
        "ui.background" = { };
      };
    };
  };

  home.stateVersion = "24.05";
}
