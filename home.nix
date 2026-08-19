{
  config,
  pkgs,
  inputs,
  ...
}: let
  dotfiles = "${config.home.homeDirectory}/NixOS/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  configs = {
    niri = "niri";
    noctalia = "noctalia";
    kitty = "kitty";
    fuzzel = "fuzzel";
    fastfetch = "fastfetch";
    helix = "helix";
  };
in {
  imports = [
    inputs.noctalia.homeModules.default
  ];

  home.username = "lucas";
  home.homeDirectory = "/home/lucas";
  home.stateVersion = "26.05";

  programs = {
    # --- Shell ---
    bash = {
      enable = true;
      shellAliases = {
        cd = "z";
      };
    };
    starship = {
      enable = true;
      settings = {
        format = "\${custom.nixos}$directory$character";
        custom.nixos = {
          command = "echo ❄";
          when = true;
          format = "[$output]($style) ";
        };
      };
    };
    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };

    # --- Desktop ---
    noctalia.enable = true;

    # --- Dev ---
    git = {
      enable = true;
      settings.user.name = "lucas-wennstrom";
      settings.user.email = "lucas.william.wennstrom@gmail.com";
      includes = [
        {
          condition = "gitdir:~/Skola/**";
          contents.user.name = "lucw380";
          contents.user.email = "lucwe380@student.liu.se";
        }
      ];
    };
  };

  # --- Fonts ---
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = ["JetBrainsMono Nerd Font"];
      sansSerif = ["JetBrainsMono Nerd Font"];
    };
  };

  xdg.configFile =
    builtins.mapAttrs
    (name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
      recursive = true;
    })
    configs;

  home.packages = with pkgs; [
    # --- Editors / IDE ---
    helix

    # --- C++ toolchain ---
    gcc
    gnumake
    cmake
    ninja
    gdb
    clang-tools
    pkg-config
    valgrind

    # --- Rust toolcain ---
    rustc
    cargo
    rust-analyzer
    rustfmt
    clippy

    # --- Other languages / Nix tooling ---
    nodejs
    nil
    nixpkgs-fmt
    alejandra

    # --- CLI utilities ---
    ripgrep
    wget
    wl-clipboard
    fastfetch
    zoxide
    git
    starship
    btop

    # --- Desktop / WM ---
    kitty
    fuzzel
    feh
    yazi

    # --- Apps ---
    spotify
    obsidian
    typst
    claude-code
    brave
  ];
}
