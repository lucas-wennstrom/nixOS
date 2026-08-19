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

  home.sessionVariables = {
    XDG_DATA_DIRS = "$HOME/.nix-profile/share:$XDG_DATA_DIRS";
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      pkgs.wayland
      pkgs.libxkbcommon
      pkgs.libdecor
      pkgs.mesa
      pkgs.libx11
      pkgs.libxcursor
      pkgs.libxi
      pkgs.libxrandr
      pkgs.libglvnd
    ];
  };

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
          condition = "gitdir:~/School/**";
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

    # --- Display ---
    wayland
    libxkbcommon
    libdecor
    mesa
    libx11
    libxcursor
    libxi
    libxrandr
    libglvnd

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
    osu-lazer-bin
  ];
}
