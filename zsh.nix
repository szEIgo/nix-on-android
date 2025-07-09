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

    # This is the direct replacement for initContent
    interactiveShellInit = ''
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
      # This assumes you have pkgs.zsh-powerlevel10k available.
      source "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
      [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

      # SSH agent setup function
      ssh_session() {
        if [ -z "$SSH_AUTH_SOCK" ]; then
          eval "$(ssh-agent -s)"
        fi
        # Add key if it's not already loaded
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

      # SDKMAN initialization
      export SDKMAN_DIR="$HOME/.sdkman"
      [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

      # SSH Keychain - ensure the keychain program is enabled below
      eval "$(keychain --eval --quiet --quick --noask --timeout 240 ${sshKey})"

      # Aliases for macOS that are not compatible with Android
      # finder() { open -a "Finder" "''${1:-.}"; }
      # dolphin() { finder "$@"; }

      # Zoxide initialization (uncomment if you add zoxide to pkgs)
      # eval "$(zoxide init zsh)"

      # Keybindings for Zsh
      bindkey "^[[3~" delete-char
      bindkey "^[[5~" beginning-of-buffer-or-history
      bindkey "^[[6~" end-of-buffer-or-history
      bindkey -M emacs '^[[3;5~' kill-word
      bindkey '^H' backward-kill-word
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word
      bindkey "^[[1;3C" forward-word
      bindkey "^[[1;3D" backward-word
      bindkey "^[[1~" beginning-of-line
      bindkey "^[[4~" end-of-line

      # Set architecture flags (useful for cross-compilation or Rosetta on macOS)
      export ARCHFLAGS="-arch $(uname -m)"
    '';
  };

  # Ensure keychain is enabled so the init script can find it
  programs.keychain.enable = true;

  # Make sure to include the packages used in the script
  home.packages = with pkgs; [
    zsh-powerlevel10k
    eza
    bat
    # zoxide # Uncomment if you use it
  ];
}