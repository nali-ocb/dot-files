{ lib, pkgs, pkgs_unstable, home_manager, ... }@inputs:

with builtins;

{
  #programs = {
  #  nm-applet = {
  #    enable = true;
  #    indicator = true;
  #  };
  #};

  environment.systemPackages = with pkgs; [
    #networkmanager
    wpa_supplicant_gui
  ];

  networking = {
    hostName = "generic";

    #networkmanager.enable = true; # Manager to make your life easier

    wireless = {
      enable = true;
      # create the wpa_supplicant.conf, so the user can use it
      # good to let laptops work without a fixed wireless config
      userControlled.enable = true;
    };
  };
}
