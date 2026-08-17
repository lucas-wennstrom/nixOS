{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      inputs.niri.nixosModules.niri
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";

  networking.networkmanager.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  systemd.services.batter-charge-threshold = {
    description = "Set Thinkpad batter-charge-threshold to 85%";
    wantedBy = [ "multi-user.target" "suspend.target" "hibernate.target" ];
    after = [ "suspend.target" "hibernate.target" ];
    serviceConfig = {
      type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "set-charge-threshold" ''
      echo 80 > /sys/class/power_supply/BAT0/charge_control_end_threshold''}";
    };
  };

  time.timeZone = "Europe/Stockholm";

  console.keyMap = "sv-latin1";

  programs.niri.enable = true;
  services.displayManager.ly = {
    enable = true;
    settings = {
      session_log = "/tmp/ly-session.log";
    };
  };

  # Screen sharing in niri goes through the GNOME portal backend,
  # which niri talks to via the same D-Bus interface Mutter uses.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "gnome" ];
  };

  nixpkgs.config.allowUnfree = true;
  users.users.lucas = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      tree
    ];
  };

  #FOR BLUETOOTH
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };
  services.blueman.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts-color-emoji
  ];

  fonts.fontconfig.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "26.05";

}

