{ lib, pkgs, pkgs_unstable, home_manager, modulesPath, ... }@inputs:

# NOTE:
# Use ‘nixos-generate-config’ to verify if the BOOT section still up-to-date

with builtins;

{
  ###########
  # NETWORK #
  ###########

  networking = {
    hostName = "shiryel";
    extraHosts = ''
      127.0.0.1 mongodb-primary
      127.0.0.1 mongodb-secondary
      127.0.0.1 mongodb-arbiter
    '';
  };

  ########
  # BOOT #
  ########

  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "ehci_pci" "usb_storage" "xhci_pci" "ahci" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  swapDevices = [
    { device = "/dev/disk/by-partlabel/cryptswap"; randomEncryption.enable = true; }
  ];

  # NOTE: not working with by-partlabel
  #boot.initrd.luks.devices."main-data".device = "/dev/disk/by-uuid/eb53efc4-11ba-4695-83c4-7b7942a3f532";
  #boot.initrd.luks.devices."main-data".keyFile = "/mnt-root/keep/luks_keyfile";

  # uuid_crypt_system
  boot.initrd.luks.devices."system".device = "/dev/disk/by-uuid/52372cf4-cc12-419b-8a71-9a263a98b3c6";

  fileSystems =
    let
      uuid_system = "bfd6c923-b9c6-4e4b-8c68-2694e03e90f3";
      uuid_crypt_data = "b8c2455b-7c7d-4dbb-b35f-e34941b711be"; # sdXY
      uuid_data = "f8e053a9-59d1-44ff-85e9-a9f19b853a81"; # dm-X
      uuid_boot = "8568-9A58";

      ssd = [ "defaults" "ssd" "compress=zstd:3" "noatime" "discard=async" "space_cache" ];
      ssd_exec = ssd ++ [ "nodev" "nosuid" ];
      ssd_noexec = ssd ++ [ "noexec" "nodev" "nosuid" ];
    in
    {
      "/keep/data" = {
        encrypted.enable = true;
        encrypted.label = "main-data";
        encrypted.blkDev = "/dev/disk/by-uuid/${uuid_crypt_data}";
        encrypted.keyFile = "/mnt-root/keep/luks_keyfile";
        device = "/dev/disk/by-uuid/${uuid_data}";
        fsType = "btrfs";
        options = [ "subvol=@data" "defaults" "noexec" "nodev" "nosuid" ];
      };

      "/" = {
        device = "tmpfs";
        fsType = "tmpfs";
        options = [ "defaults" "nodev" "nosuid" "mode=755" ];
      };

      "/boot" = {
        device = "/dev/disk/by-uuid/${uuid_boot}";
        fsType = "vfat";
      };

      "/nix" = {
        device = "/dev/disk/by-uuid/${uuid_system}";
        fsType = "btrfs";
        options = [ "subvol=@nix" "nodev" ] ++ ssd;
      };

      "/var" = {
        device = "/dev/disk/by-uuid/${uuid_system}";
        fsType = "btrfs";
        options = [ "subvol=@var" ] ++ ssd_noexec;
      };

      "/etc" = {
        device = "/dev/disk/by-uuid/${uuid_system}";
        fsType = "btrfs";
        options = [ "subvol=@etc" ] ++ ssd_noexec;
      };

      "/home" = {
        device = "/dev/disk/by-uuid/${uuid_system}";
        fsType = "btrfs";
        options = [ "subvol=@home" ] ++ (lib.remove "noatime" ssd_exec);
      };

      "/.snapshots" = {
        device = "/dev/disk/by-uuid/${uuid_system}";
        fsType = "btrfs";
        options = [ "subvol=@snapshots" ] ++ ssd_noexec;
      };

      "/keep" = {
        device = "/dev/disk/by-uuid/${uuid_system}";
        fsType = "btrfs";
        options = [ "subvol=@keep" ] ++ ssd_noexec;
        neededForBoot = true;
      };

      "/keep/games" = {
        device = "/dev/disk/by-uuid/${uuid_system}";
        fsType = "btrfs";
        options = [ "subvol=@games" ] ++ ssd_exec;
      };
    };

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

# TUTORIAL:

# GENERATING KEYFILE
# openssl genrsa -out $DEST 4096
# (make sure only root can read)
#
# ADD KEYFILE
# cryptsetup luksAddKey $DEVICE $DEST
