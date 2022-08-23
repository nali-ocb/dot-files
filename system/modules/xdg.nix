###########################################################
# This file configures XDG
#
# NOTE:
# Mime directories:
# - System: /run/current-system/sw/share/applications/mimeinfo.cache
# - Home: ~/.config/mimeapps.list
#
# DOCS:
# - To get a list of mimes and apps
#   mimeo --app2mime [appname] and --app2desk [appname]
#   handlr --list
#
# - Mimes: https://github.com/isamert/jaro/blob/master/data/mimeapps.list
#   Load from: echo $XDG_DATA_DIRS
###########################################################

{ lib, pkgs, pkgs_unstable, ... }@inputs:

{
  # - Run screenshare wayland and containerized apps (better)
  #   Needs that sway register on systemd that it started
  xdg.portal.enable = true;
  xdg.portal.wlr.enable = true;

  xdg.mime.defaultApplications = {
    "x-scheme-handler/http" = [
      "firefox.desktop"
      "librewolf.desktop"
      "chromium-browser.desktop"
    ];
    "x-scheme-handler/https" = [
      "firefox.desktop"
      "librewolf.desktop"
      "chromium-browser.desktop"
    ];
    "application/x-extension-html" = [
      "firefox.desktop"
      "librewolf.desktop"
      "chromium-browser.desktop"
    ];
    "application/pdf" = "firefox.desktop";
    "application/json" = "nvim.desktop";
    "text/*" = "nvim-qt.desktop";
    "audio/*" = "mpv.desktop";
    "video/*" = "mpv.desktop";
    "image/*" = [
      "imv.desktop"
      "firefox.desktop"
      "org.kde.krita.desktop"
    ];
  };
}
