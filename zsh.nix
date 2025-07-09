{ config, pkgs, lib, ... }:

let
  # Define the path to your SSH key
  sshKey = "~/.ssh/id_ed25519";
in
{
  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      default_layout = "compact";
      default_shell = "zsh";
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autocd = true;

    oh-my-zsh = {
      enable = true;
      theme = ""; # An empty theme is needed to use an external one like Powerlevel10k
      plugins = [
        "git"
        "sudo"
        "vi-mode"
        "cp"
        "history"
        "colorize"
        # The following plugins might not be as useful on Android
        # but are kept as per your original config.
        "terraform"
        "systemadmin"
        "scala"
        "rust"
        "redis-cli"
        "kubectl"
        "podman"
        "aws"
      ];
    };

    shellAliases = {
      l = "eza --icons";
      la = "eza --icons -a";
      ll = "eza --icons -lah";
      ls = "eza --icons --color=auto";
      docker = "podman";
      vim = "hx";
      cat = "bat --style plain --pager never"; # Alias for bat
      sw_debian = "ssh -J bastion@51.158.121.209:61000 root@172.16.16.5";
      sw_ubuntu = "ssh -J bastion@51.15.132.29:61000 root@172.16.4.2";
    };
  };

  programs.keychain.enable = true;

  home.packages = with pkgs; [
    zsh-powerlevel10k
    eza
    bat
    # zoxide # Uncomment if you use it
  ];
}