{ config, pkgs, lib, ... }:

let
  sshKey = "~/.ssh/id_ed25519";

  zsh_custom_script = ''
    # Locale settings
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8

    # Zsh history settings
    setopt HIST_FCNTL_LOCK
    setopt HIST_IGNORE_DUPS
    setopt HIST_IGNORE_SPACE
    setopt SHARE_HISTORY
    HIST_STAMPS="mm/dd/yyyy"

    # Powerlevel10k theme
    # source "''${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
    # [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

    # SSH agent setup function
    ssh_session() {
      if [ -z "$SSH_AUTH_SOCK" ]; then
        eval "$(ssh-agent -s)"
      fi
      if ! ssh-add -l &>/dev/null; then
        ssh-add ${sshKey} &>/dev/null
      fi
    }

    # Override common commands to ensure the SSH agent is running
    ssh() {
      ssh_session
      command ssh -X -CY -o ServerAliveInterval=120 "$@"
    }
    scp() {
      ssh_session
      command scp -C -v -r -o StrictHostKeyChecking=no "$@"
    }
    git() {
      ssh_session
      command git "$@"
    }


    # SSH Keychain
    eval "$(keychain --eval --quiet --quick --noask --timeout 240 ${sshKey})"

    # Keybindings for Zsh
    bindkey "^[[3~" delete-char
    bindkey "^[[5~" beginning-of-buffer-or-history
    bindkey "^[[6~" end-of-buffer-or-history
  '';

in
{
  # 1. Create a file in the home directory with our script
  home.file.".zsh_custom" = {
    text = zsh_custom_script;
    executable = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autocd = true;

   enableFzfHistory.enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "cloud";
      plugins = [
        "git"
        "sudo"
        "vi-mode"
        "cp"
        "history"
        "colorize"
      ];
    };

    shellAliases = {
      l = "eza --icons";
      la = "eza --icons -a";
      ll = "eza --icons -lah";
      docker = "podman";
      vim = "hx";
      cat = "bat --style plain --pager never";
      build = "nix-on-droid build --flake /data/data/com.termux.nix/files/home/.config/nix-on-droid";
    };

    # 2. Tell .zshrc to source the file we just created
    initExtra = "source ''/data/data/com.termux.nix/files/home/.zsh_custom";
  };

  programs.keychain.enable = true;

  home.packages = with pkgs; [
    zsh-powerlevel10k
    eza
    bat
    keychain
  ];
}