{ config, pkgs, inputs, ... }:
  let 
    dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
    create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
    configs = {
      niri = "niri";
      noctalia = "noctalia";
      nvim = "nvim";
      kitty = "kitty";
      fuzzel = "fuzzel";
      thunar = "thunar";
      fastfetch = "fastfetch";
    };
  in
  {
  imports = [
    inputs.noctalia.homeModules.default
  ];

  home.username = "lucas";
  home.homeDirectory = "/home/lucas";
  home.stateVersion = "26.05";
  programs = {
	bash.enable = true;
	noctalia.enable = true;
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
  git = {
    enable = true;
    settings.user.name = "lucas-wennstrom";
    settings.user.email= "lucas.william.wennstrom@gmail.com";
  includes = [
    {
      condition ="gitdir:~/Skola/**";
      contents.user.name = "lucw380";
      contents.user.email = "lucwe380@student.liu.se";
    }
  ];
  };
  };


  xdg.configFile = builtins.mapAttrs
    (name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
      recursive = true;
    })
    configs;

  home.packages = with pkgs; [
    neovim
	  vscode
	  ripgrep
	  nil
	  nixpkgs-fmt
	  nodejs
	  gcc
    fastfetch
  	feh
	  fuzzel
	  wl-clipboard
	  starship
    spotify
    discord
    claude-code
    inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
    wget
    kitty
    obsidian
    git
  ];
}
