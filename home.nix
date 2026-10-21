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
    kitty = "kitty";
    fastfetch = "fastfetch";
    helix = "helix";
  };
in {
  imports = [
    inputs.noctalia.homeModules.default
  ];

  services.kanshi = {
    enable = true;
    settings = [
      {
        profile.name = "docked";
        profile.outputs = [
          {
            criteria = "DP-1";
            status = "enable";
          }
          {
            criteria = "eDP-1";
            status = "enable";
          }
        ];
      }
      {
        profile.name = "undocked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
          }
        ];
      }
    ];
  };

  home.username = "lucas";
  home.homeDirectory = "/home/lucas";
  home.stateVersion = "26.05";

  programs = {
    # --- Shell ---
    bash = {
      enable = true;
      # Some launchers export NO_COLOR, which disables Helix syntax colours.
      initExtra = ''
        unset NO_COLOR
      '';
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
      options = ["--cmd" "cd"];
    };

    # --- Desktop ---
    noctalia.enable = true;

    # --- Dev ---
    git = {
      enable = true;
      settings = {
        init.defaultBranch = "main";
        user = {
          name = "lucas-wennstrom";
          email = "lucas.william.wennstrom@gmail.com";
        };
      };
      includes = [
        {
          condition = "gitdir:~/School/**";
          contents.user.name = "lucw380";
          contents.user.email = "lucwe380@student.liu.se";
        }
      ];
    };

    codex.enable = true;
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
    zed-editor

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
    xwayland-satellite

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
    rustup

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

    # --- Desktop / WM ---
    kitty
    fuzzel
    feh

    # --- Apps ---
    spotify
    obsidian
    typst
    brave
    unzip
  ];
}
