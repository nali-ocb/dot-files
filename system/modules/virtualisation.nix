###########################################################
# This file configures the virtualisations on the machine
#
# How to configure via terminal:
# - Create a image disk:
#   https://qemu-project.gitlab.io/qemu/system/images.html
# - Know your options
#   https://qemu-project.gitlab.io/qemu
#   https://wiki.gentoo.org/wiki/QEMU/Options
# - Connect with adb
#   https://www.android-x86.org/documentation/debug.html
# 
# Example:
# - qemu-img create android.img 30G
# - qemu-kvm -soundhw es1370 -net nic -net user,hostfwd=tcp::4444-:5555 -m 3G -smp 2 -hda android.img -cdrom android-x86_64.iso
#
# DOCS:
# - https://nixos.wiki/wiki/Virt-manager
# - https://www.youtube.com/watch?v=wxxP39cNJOs
# - https://nixos.wiki/wiki/Libvirt
# - https://nixos.wiki/wiki/OSX-KVM
# - https://discourse.nixos.org/t/networkd-libvirt-bridged-networking-how/11769/4
# - http://ayekat.ch/blog/qemu-networkd
#
###########################################################

{ config, lib, pkgs, ... }:

{
  #
  # Podman
  #
  virtualisation.docker.enable = lib.mkForce false;
  virtualisation.podman = {
    enable = true;
    extraPackages = with pkgs; [ ];
    dockerCompat = true;
    dockerSocket.enable = true;
    defaultNetwork.dnsname.enable = true;
  };

  users.extraGroups.podman.members = [ "nali" "work" ];

  ###################
  # Virtualisations #
  ###################

  # - Enables KVM (also, libvirtd needs to work with android)
  #   https://specific.solutions.limited/projects/hanging-plotter/android-environment.md
  boot.kernelModules = [ "kvm-amd" ];

  #
  # VirtualBox
  #

  # virtualisation.virtualbox.host.enable = true;
  # users.extraGroups.vboxusers.members = [ "nali" ];

  #
  # KVM/QEMU
  #
  # NOTE: current has a problem with iptables
  # With the command: sudo iptables --list

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu.runAsRoot = false;
    #allowedBridges = [ "virbr0" "virbr1" "virbr2" ];
  };
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [ virt-manager ];

  users.extraGroups.qemu-libvirtd.members = [ "nali" ];
}
