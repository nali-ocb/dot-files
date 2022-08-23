{ pkgs, pkgs_unstable, ... }@inputs:

{
  xdg.configFile."kitty/kitty.conf".source = ./kitty.conf;
  home.packages = with pkgs; [ kitty ];
}
