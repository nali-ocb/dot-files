SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

#for i in `ls "$SCRIPTPATH/dotfiles"`; {
#  ln -fsv "$SCRIPTPATH/dotfiles/$i" "$HOME/.$i"
#}
#
#mkdir -p "$HOME/.config"
#
#for i in `ls "$SCRIPTPATH/config"`; {
# FIXME: when is first time will show a error
#  rm -vr "$HOME/.config/$i"
#  ln -fsv "$SCRIPTPATH/config/$i" "$HOME/.config/$i"
#}
#
#for i in `ls "$SCRIPTPATH/desktop"`; {
#  # FIXME: when is first time will show a error
#  rm -vr "$HOME/.local/share/applications/$i"
#  ln -fsv "$SCRIPTPATH/desktop/$i" "$HOME/.local/share/applications/$i"
#}

#sudo rm /etc/nixos/nixos_configs
#sudo rm /etc/nixos/lib
#sudo rm /etc/nixos/utils.nix

#sudo ln -s "$SCRIPTPATH/nixos_configs" /etc/nixos/nixos_configs
#sudo ln -s "$SCRIPTPATH/utils.nix" /etc/nixos/utils.nix
sudo rm /etc/nixos/configuration.nix
sudo ln -s "$SCRIPTPATH/../configuration.nix" /etc/nixos/configuration.nix

rm "$SCRIPTPATH/../hardware-configuration.nix"
ln -s /etc/nixos/hardware-configuration.nix "$SCRIPTPATH/../hardware-configuration.nix"
