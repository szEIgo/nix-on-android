{ config, lib, pkgs, ... }:

{
  # Simply install just the packages
  environment.packages = with pkgs; [
    zellij
    fzf
     git
     htop
     zsh-powerlevel10k
     oh-my-zsh
    vim
    procps
    killall
    diffutils
    findutils
    utillinux
    tzdata
    hostname
    man
    gnugrep
    gnupg
    gnused
    gnutar
    bzip2
    gzip
    xz
    zip
    unzip
    zoxide
    zsh
    eza
    bat
    age
    zsh-history
    keychain
    vim
    btop
    wget
    nmap
    ripgrep
    jq
    sbt
    scala
    rustc
    cargo
    rustfmt
    ncdu
    tree
    dust
    tmux
    helix
    copyq
    fd
    wireguard-tools
    atop
    netdata
    openssh
  ];

  environment.etcBackupExtension = ".bak";

  system.stateVersion = "24.05";

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  time.timeZone = "Europe/Copenhagen";

  home-manager = {
    config = ./joni.nix;
    backupFileExtension = "hm-bak";
    useGlobalPkgs = true;
  };
}
