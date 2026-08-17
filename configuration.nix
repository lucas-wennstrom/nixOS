{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    inputs.niri.nixosModules.niri
  ];

  # --- Boot ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 4;

  # --- Networking ---
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # --- Power management ---
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  systemd.services.batter-charge-threshold = {
    description = "Set Thinkpad battery charge threshold to 80%";
    wantedBy = ["multi-user.target" "suspend.target" "hibernate.target"];
    after = ["suspend.target" "hibernate.target"];
    serviceConfig = {
      type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "set-charge-threshold" ''
          echo 80 > /sys/class/power_supply/BAT0/charge_control_end_threshold''}";
    };
  };

  # --- Locale ---
  time.timeZone = "Europe/Stockholm";
  console.keyMap = "sv-latin1";

  # --- Desktop ---
  programs.niri.enable = true;
  services.displayManager.ly = {
    enable = true;
    settings = {
      session_log = "/tmp/ly-session.log";
    };
  };

  # --- Audio ---
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- Desktop portals ---
  # Portals talk to niri over the same D-Bus interface Mutter uses.
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [pkgs.xdg-desktop-portal-gnome pkgs.xdg-desktop-portal-gtk];
    config.common.default = ["gtk"];
  };

  # --- Bluetooth ---
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };
  services.blueman.enable = true;

  # --- Fonts ---
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts-color-emoji
  ];
  fonts.fontconfig.enable = true;

  # --- Users ---
  users.users.lucas = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    packages = with pkgs; [
      tree
    ];
  };

  # --- Nix ---
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 3d";
  };
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "26.05";
}
