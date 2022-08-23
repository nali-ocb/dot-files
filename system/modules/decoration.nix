###########################################################
# This file configures your fonts
###########################################################

{ pkgs, pkgs_unstable, ... }:

{
  ##########
  # Themes #
  ##########

  environment.variables = {
    GTK_THEME = "Adwaita:dark";
  };

  qt5 = {
    enable = true;
    style = "adwaita-dark"; # set QT_STYLE_OVERRIDE
    platformTheme = "gnome"; # set QT_QPA_PLATFORMTHEME
  };

  environment.systemPackages = with pkgs; [
    # dep of qt5.platformTheme = "gnome";
    qgnomeplatform
    # dep of qt5.platformTheme = "gtk2";
    #qtstyleplugins
  ];

  #########
  # Fonts #
  #########

  # Font/DPI configuration optimized for HiDPI displays
  #hardware.video.hidpi.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  fonts = {
    fontconfig.enable = true;
    fontDir.enable = true;

    enableDefaultFonts = true;
    enableGhostscriptFonts = true;

    fonts = with pkgs; [
      (nerdfonts.override {
        enableWindowsFonts = true;
      })
      carlito
      dejavu_fonts
      fira
      fira-code
      fira-mono
      inconsolata
      inter
      inter-ui
      libertine
      noto-fonts
      noto-fonts-emoji
      noto-fonts-extra
      roboto
      roboto-mono
      roboto-slab
      source-code-pro
      source-sans-pro
      source-serif-pro
      twitter-color-emoji
      corefonts
    ];

    # cd /nix/var/nix/profiles/system/sw/share/X11/fonts
    # fc-query DejaVuSans.ttf | grep '^\s\+family:' | cut -d'"' -f2 
    fontconfig.defaultFonts = {
      sansSerif = [ "Source Sans Pro" ];
      serif = [ "Source Serif Pro" ];
      monospace = [ "Cousine Nerd Font Mono" ];
      emoji = [ "Twitter Color Emoji" ];
    };
  };
}
