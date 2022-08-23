# TODO: https://grahamc.com/blog/erase-your-darlings
# TODO: https://cnx.srht.site/blog/butter/index.html

{ lib, pkgs, pkgs_unstable, home_manager, ... }@inputs:

with builtins;

{
  ###############
  # NIX CONFIGS #
  ###############

  # Enable Flakes
  nix = {
    package = pkgs.nixFlakes; # or versioned attributes like nix_2_7
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    gc = {
      automatic = true;
      persistent = true;
      dates = "weekly";
      options = "--delete-old --delete-older-than 15d";
    };
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
  };
  programs.nix-ld.enable = true;

  ##########
  # MOUNTS #
  ##########

  # use `findmnt -l` to see the fileSystems
  services.btrfs.autoScrub.enable = true;
  services.btrfs.autoScrub.interval = "weekly";

  ###########
  # MODULES #
  ###########

  imports =
    [
      # System Wide
      ./modules/bwrap.nix
      ./modules/intel.nix
      ./modules/security.nix
      ./modules/network.nix
      ./modules/keyboard_moonlander.nix
      ./modules/decoration.nix
      ./modules/virtualisation.nix
      ./modules/xdg.nix

      # Home Manager
      # https://rycee.gitlab.io/home-manager/
      home_manager
      {
        # use the global pkgs that is configured via the
        # system level nixpkgs options
        home-manager.useGlobalPkgs = true;
        # prefer using packages from user instead of environment.systemPackages
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs =
          let
            system_lib = lib; # just changing the name to avoid the conflict
          in
          { inherit system_lib pkgs pkgs_unstable; };
        home-manager.users = {
          nali.imports = [ ../home_manager/nali.nix ];
          #work.imports = [ ../home_manager/work.nix ];
        };
      }
    ];

  ######################
  # HOME MANAGER FIXES #
  ######################
  # System wide configs to make stuf work on Home Manager
  #

  # Fix swaylock not unlocking:
  # https://github.com/nix-community/home-manager/issues/2017
  security.pam.services.swaylock = { };

  ##################
  # SYSTEM GENERAL #
  ##################

  users =
    let
      # define initial password with: mkpasswd -m sha-512
      pass = "$6$VVk6JhH6amORp67o$HXhfWKkzSLl7u9BYbW/TRkpoEPagy2CRKamwKARquOG1DYy/awu.2WT33QeVM6WsnbnoMcM8pTE2UrQbm2e22.";
    in
    {
      mutableUsers = true;
      # admin
      users.alpha = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        hashedPassword = pass;
      };
      # normal users
      users.nali = {
        isNormalUser = true;
        extraGroups = [ ];
        hashedPassword = pass;
      };
      users.work = {
        isNormalUser = true;
        hashedPassword = pass;
      };
      defaultUserShell = pkgs.zsh;
    };

  documentation = {
    man.enable = true;
    dev.enable = true;
    nixos.enable = true;
  };

  services.searx = {
    enable = true;
    settings = {
      server.port = 8888;
      server.bind_address = "127.0.0.1";
      server.secret_key = (
        # Not the bests of the secrets, but this is only for the API
        # and as much the firewall is ON this is not a concern,
        # unfortunately, its required by Searx
        toString (lib.trivial.oldestSupportedRelease / 3.0) +
        toString (lib.trivial.oldestSupportedRelease / 0.3) +
        lib.version
      );
    };
  };

  # Use the systemd-boot EFI boot loader.
  # NOTE: some aditional modules are add were they were due
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time = {
    timeZone = "Asia/Kolkata";
    hardwareClockInLocalTime = true;
  };

  services = {
    # https://nixos.wiki/wiki/PipeWire
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    gnome.sushi.enable = true; # nautilus image preview

    # Fixes for android file transfer and 
    # https://wiki.archlinux.org/title/Java#Java_applications_cannot_open_external_links
    gvfs.enable = true;
  };

  hardware.steam-hardware.enable = true; # let controlers work

  ############
  # PROGRAMS #
  ############

  programs = {
    zsh = {
      enable = true;
      histSize = 100000;
      vteIntegration = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      syntaxHighlighting.highlighters = [ "main" "brackets" "pattern" "cursor" "root" "line" ];
      shellInit = ''
        # fix ctrl + left/right
        bindkey "^[[1;5C" forward-word
        bindkey "^[[1;5D" backward-word
      '';
    };
    evince.enable = true; # pdf preview support for gnome apps (eg, nautilus)
    npm.enable = true;
    #wireshark.enable = true;
    #wireshark.package = pkgs.wireshark;

    # Some programs need SUID wrappers, can be configured further or 
    # are started in user sessions.
    mtr.enable = true;
  };

  environment.variables = {
    # avoid running ranger RC 2 times
    RANGER_LOAD_DEFAULT_RC = "FALSE";
    # force flutter to use chromium
  };

  environment.shellAliases = {
    telegram = "telegram-desktop -workdir $HOME/.telegram";
    start-postgres = "podman run -d --name postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 postgres";
    start-mongodb = "podman run -d --name mongodb -p 27017:27017 mongo";
    record = "wf-recorder --audio='alsa_output.pci-0000_28_00.3.analog-stereo.monitor'";
    # https://github.com/ibraheemdev/modern-unix
    df = "duf";
    gtop = "glances";
    htop = "btm --color gruvbox";
    ports = "sudo lsof -i -P -n | grep LISTEN";
    ports_all = "sudo lsof -i -P -n";
    # or sudo netstat -tulpn | grep LISTEN
    # or sudo ss -tulpn | grep LISTEN
    unzip = "unar";
    # -device ES1370 # sound
    # -m # memory size
    # -smp # CPU cores
    # -hda # disk, create with: `qemu-img create android.img 30G`
    # -usbdevice tablet # FIX mouse stutter, but its slower
    run-android = "qemu-kvm -device ES1370 -net nic -net user,hostfwd=tcp::5555-:5555 -m 3G -smp 4 -hda android.img -cdrom android-x86_64.iso -usbdevice tablet";
    # qemu-kvm -device ES1370 -net nic -net user,hostfwd=tcp::4444-:5555 -m 3G -smp 4 -hda android.img -cdrom android-x86_64.iso -usbdevice tablet -usb -device qemu-xhci -device usb-host,vendorid=0x04d9,productid=0xfc5d
    # emulator <options-for-android> -qemu <options-for-qemu>
    admin = "sudo - admin";
  };

  services.udev.packages = [ pkgs.android-udev-rules ];

  environment.systemPackages = with pkgs; [
    unzip
    unar # unrar free
    p7zip
    vim
    usbutils

    #
    # Modern unix
    #
    kitty
    bottom # htop
    glances # top
    duf # df
    ncdu # nice du
    procs # ps
    cheat
    tldr
    curl
    wget
    git
    ranger
    deer

    #
    # Linux Admin
    #
    lsof # ls open files
    inetutils
    ntfs3g
    killall
    smartmontools # SMART device tests
    inxi
    # used to debug input devices
    # eg: sudo libinput debug-events
    libinput

    # nix
    vulnix
    #nix-doc
    nixdoc
    manix
    #arion

    #
    # Avoid installing from HM for security reasons
    #
    pinentry
    keepassxc
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
