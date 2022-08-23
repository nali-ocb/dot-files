{ lib, pkgs, pkgs_unstable, home_manager, ... }@inputs:

with builtins;

{
  environment.systemPackages = with pkgs; [
    wpa_supplicant_gui
  ];

  networking = {
    hostName = "nali-notebook";

    wireless = {
      enable = true;
      # create the wpa_supplicant.conf, so the user can use it
      # good to let laptops work without a fixed wireless config
      userControlled.enable = true;
    };
  };
}
