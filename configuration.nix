{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    inputs.niri.nixosModules.niri
  ];

  services.flatpak.enable = true;
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

  # --- VM ---
  boot.kernelModules = ["kvm-amd"]; # Use only the one relevant to your CPU
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  systemd.tmpfiles.rules = ["L+ /var/lib/qemu/firmware - - - - ${pkgs.qemu}/share/qemu/firmware"];

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

  environment.sessionVariables.XDG_DATA_DIRS = [
    "/var/lib/flatpak/exports/share"
    "$HOME/.local/share/flatpak/exports/share"
  ];

  # --- Bluetooth ---
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
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
    extraGroups = ["wheel" "networkmanager" "libvirtd"];
    packages = with pkgs; [
      tree
      widevine-cdm
    ];
  };

  # --- Nix ---
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;
  };
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 3d";
  };
  nixpkgs.config.allowUnfree = true;

  # --- Graphics ---
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.opentabletdriver.enable = true;
  boot.blacklistedKernelModules = ["wacom"];

  environment.systemPackages = with pkgs; [
    xorg.xrandr
    iw
    wireguard-tools
    (brave.override {
      commandLineArgs = [
        "--ozone-platform-hint=auto"
        "--enable-features=VaapiVideoDecodeLinuxGL"
        "--ignore-gpu-blocklist"
      ];
    })
  ];

  system.stateVersion = "26.05";
}
