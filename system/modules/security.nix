###########################################################
# This file configures your security, with:
# - firewall
# - opensnitch
# - gnupg
# - hardened linux kernel & config
# - kernel audit
#
# TEST:
# - To see the logs from Kernel Audit:
#   sudo journalctl -u audit
#
# DOCS: (references)
# - https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/profiles/hardened.nix
# - https://dataswamp.org/~solene/2022-01-13-nixos-hardened.html
#
# TODO: 
# - add dotfiles to admin user and make it ready-only to shiryel and work
# - maybe add chkrootkit or lynis
###########################################################

{ lib, pkgs, pkgs_unstable, channels, ... }@inputs:

{
  services.dbus.apparmor = "enabled";

  # GNOME Keyring
  #services.gnome.gnome-keyring.enable = true;
  #environment.systemPackages = with pkgs; [ libsecret ];
  #
  # Testing:
  # - ssh -T git@github.com
  # - echo "a" | gpg --sign

  programs.ssh = {
    # NOTE: `AddKeysToAgent yes` is configured on home-manager
    #startAgent = true;
    # to set how it will ask: 
    # environment.SSH_ASKPAS
    # or programs.ssh.askPassword and programs.ssh.enableAskPassword
  };
  services.openssh = {
    enable = true;
    passwordAuthentication = lib.mkForce false;
    openFirewall = lib.mkForce false;
    permitRootLogin = lib.mkForce "no";
    startWhenNeeded = true;
  };
  programs.gnupg.agent = {
    enable = true;
    # cache SSH keys added by the ssh-add
    enableSSHSupport = true;
    # set up a Unix domain socket forwarding from a remote system
    # enables to use gpg on the remote system without exposing the private keys to the remote system
    enableExtraSocket = false;
    # allows web browsers to access the gpg-agent daemon
    enableBrowserSocket = false;
    # NOTE: "gnome3" flavor only works with Xorg
    # To reload config: gpg-connect-agent reloadagent /bye
    pinentryFlavor = "gtk2"; # use "tty" for console only
  };

  networking = {
    firewall = {
      enable = true;
      # 14159 -> Necesse
      # 15937 -> RAOT
      allowedTCPPorts = [ 14159 15937 ];
      allowedUDPPorts = [ 14159 15937 ];
    };
    # - configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };

  services = {
    # - enable antivirus clamav and keep the signatures' database updated
    clamav.daemon.enable = true;
    clamav.updater.enable = true;
    # - Application firewall
    opensnitch = {
      enable = true;
      settings = {
        Firewall = "iptables";
        DefaultDuration = "always";
        DefaultAction = "deny";
        ProcMonitorMethod = "ebpf";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    opensnitch-ui
    gnupg
    clamav
  ];

  # - xdg is unecessary
  xdg.autostart.enable = lib.mkForce false;

  # - Kernel (default: LTS)
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages = pkgs.linuxPackages_hardened;
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
  boot.kernelPackages = pkgs.linuxPackages_zen;

  security = {
    # - required by podman to run containers in rootless mode when using linuxPackages_hardened
    unprivilegedUsernsClone = true;
    # - prevent replacing the running kernel image
    protectKernelImage = true;
    # - packages and services can dynamically load kernel modules
    lockKernelModules = false;
    # - to build packages from source
    allowUserNamespaces = true;
    # - Kernel Audit
    # * DOCS: 
    #   - https://wiki.archlinux.org/title/Audit_framework
    #   - auditctl -h
    audit = {
      enable = true;
      rules = [
        "-w /home/nali/data/docs/secrets -p rwxa"
      ];
    };
    # - RealtimeKit is optional but recommended
    #   Hands out realtime scheduling priority to user processes on demand
    rtkit.enable = true;
  };

  boot.blacklistedKernelModules = [
    # - Obscure network protocols
    "ax25"
    "netrom"
    "rose"

    # - Old or rare or insufficiently audited filesystems
    "adfs"
    "affs"
    "bfs"
    "befs"
    "cramfs"
    "efs"
    "erofs"
    "exofs"
    "freevxfs"
    "f2fs"
    "hfs"
    "hpfs"
    "jfs"
    "minix"
    "nilfs2"
    "ntfs"
    "omfs"
    "qnx4"
    "qnx6"
    "sysv"
    "ufs"
  ];

  #######
  # TPM #
  #######
  #
  # Trusted Platform Module (TPM) is an international standard for a secure cryptoprocessor, 
  # which is a dedicated microprocessor designed to secure hardware by integrating 
  # cryptographic keys into devices. 
  # - https://security.stackexchange.com/questions/187820/do-a-tpms-benefits-outweigh-the-risks
  #   Another criticism is that it may be used to prove to remote websites that you are running the software they want you to run, or that you are using a device which is not fully under your control. The TPM can prove to the remote server that your system's firmware has not been tampered with, and if your system's firmware is designed to restrict your rights, then the TPM is proving that your rights are sufficiently curtailed and that you are allowed to watch that latest DRM-ridden video you wanted to see. Thankfully, TPMs are not currently being used to do this, but the technology is there.
  #   TPMs make me nervous because a hardware failure could render me unable to access my own keys and data. That seems more likely than a black hat hacker pulling off a root kit on my OS." - https://youtu.be/RW2zHvVO09g
  security.tpm2 = {
    enable = false;
    # - userspace resource manager daemon
    abrmd.enable = false;
  };

  ##################################
  # Memory Allocator (not working) #
  ##################################
  #
  # discord "sys_waitpid() for gzip process failed."
  #environment.memoryAllocator.provider = "jemalloc";
  # nixos-rebuild throw "Out of memory"
  #environment.memoryAllocator.provider = "graphene-hardened";
  # firefox not opening
  #environment.memoryAllocator.provider = "scudo";
  #environment.variables.SCUDO_OPTIONS = "ZeroContents=1"; # zero chunk contents on allocation.
}
