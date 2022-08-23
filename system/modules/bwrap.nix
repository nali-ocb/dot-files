###########################################################
# This file configures your bwraped packages
# Isolating them from the rest of the system
#
# The lib.bwrap is custom, take a look at lib/bwrap.nix
#
# This file configures:
# - firefox
# - librewolf
# - chromium
# - telegram
# - thunderbird
# - discord
# - postman
# - android-studio
# - minecraft
# - wine
# - steam
#
# DOCS:
# - Mimes: https://github.com/isamert/jaro/blob/master/data/mimeapps.list
#   Load from: echo $XDG_DATA_DIRS
#   Usually at: /run/current-system/sw/share/applications
#   Tutorial: https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/make-desktopitem/default.nix
#
###########################################################

{ lib, pkgs, pkgs32, pkgs_unstable, home_manager, config, ... }@inputs:

let
  common_binds = [
    "~/Downloads"
  ];

  data_binds = [
    "/keep/data/docs/work"
    "~/data/docs/work"
    "/keep/data/docs/books"
    "~/data/docs/books"
    "/keep/data/projects/drawings"
    "~/data/projects/drawings"
    "~/projects/drawings"
  ];

  code_binds = [
    "/keep/data/projects"
    "~/data/projects"
    "~/projects"
  ];

  game_binds = [
    "/keep/games"
    "~/games"
  ];
in
{
  programs.neovim.enable = lib.mkForce false;
  environment.variables = {
    EDITOR = "vim";
    VISUAL = "vim";
  };
  environment.systemPackages = with pkgs;
    [
      bubblewrap

      # GENERIC WRAPPER
      (pkgs.writeScriptBin "wrap"
        ''
          #!${pkgs.stdenv.shell}
          mkdir -p ~/bwrap/generic_wrap

          exec ${lib.getBin pkgs.bubblewrap}/bin/bwrap \
            --ro-bind /run /run \
            --ro-bind /bin /bin \
            --ro-bind /etc /etc \
            --ro-bind /nix /nix \
            --ro-bind /sys /sys \
            --ro-bind /var /var \
            --ro-bind /usr /usr \
            --dev /dev \
            --proc /proc \
            --tmpfs /tmp \
            --tmpfs /home \
            --die-with-parent \
            --unshare-all \
            --new-session \
            --dev-bind /dev /dev \
            --bind-try ~/bwrap/generic_wrap ~/ \
            $@
        '')

      # WORK ENV WRAPPER
      # NOTE:
      # - GPG key needs to be on both host and guest user to work
      (lib.bwrapIt {
        name = "work";
        package = kitty;
        exec = "bin/kitty";
        args = "$@";
        net = true;
        dri = true;
        binds = [
          {
            from = "~/bwrap/work";
            to = "~/";
          }
        ] ++ code_binds;
        custom_config = [
          "--ro-bind ~/.zshenv ~/.zshenv"
          "--ro-bind ~/.zshrc ~/.zshrc"
        ];
      })

      # CODING ENV WRAPPER
      (lib.bwrapIt {
        name = "code";
        package = kitty;
        exec = "bin/kitty";
        args = "$@";
        net = true;
        dev = true;
        binds = [
          {
            from = "~/bwrap/code";
            to = "~/";
          }
        ] ++ code_binds;
        custom_config = [
          "--ro-bind ~/.zshenv ~/.zshenv"
          "--ro-bind ~/.zshrc ~/.zshrc"
        ];
      })

      ############
      # BROWSERS #
      ############

      # firefox
      (lib.bwrapIt {
        name = "firefox";
        package = firefox;
        args = "\"$@\""; # lets links open
        net = true;
        dri = true;
        binds = [
          {
            from = "~/bwrap/mozilla";
            to = "~/.mozilla";
          }
        ] ++ common_binds ++ data_binds;
        custom_config = [
          "--setenv MOZ_ENABLE_WAYLAND 1"
          "--setenv MOZ_USE_XINPUT2 1"
        ];
      })
      (pkgs.makeDesktopItem {
        name = "firefox";
        desktopName = "Firefox";
        genericName = "Web Browser";
        type = "Application";
        icon = "firefox";
        terminal = false;
        mimeTypes = [ "text/html" "text/xml" "application/xhtml+xml" "application/vnd.mozilla.xul+xml" "x-scheme-handler/http" "x-scheme-handler/https" "x-scheme-handler/ftp" ];
        categories = [ "Network" "WebBrowser" ];
        exec = "firefox %U";
      })

      # librewolf
      (lib.bwrapIt {
        name = "librewolf";
        package = librewolf-wayland;
        net = true;
        dri = true;
        binds = [
          {
            from = "~/bwrap/librewolf";
            to = "~/.librewolf";
          }
        ] ++ common_binds;
      })

      # chromium
      (lib.bwrapIt {
        name = "chromium";
        package = ungoogled-chromium;
        net = true;
        dev_bind = true; # webcam support
        binds = [
          {
            from = "~/bwrap/chromium";
            to = "~/";
          }
        ] ++ common_binds ++ data_binds;
      })

      # tor-browser
      (lib.bwrapIt {
        name = "tor-browser";
        package = tor-browser-bundle-bin;
        binds = [ ];
      })

      ########
      # CHAT #
      ########

      # telegram
      (lib.bwrapIt {
        name = "telegram-desktop";
        package = tdesktop;
        net = true;
        dri = true;
        xdg = true;
        binds = [
          {
            from = "~/bwrap/telegram";
            to = "~/";
          }
          "~/bwrap/mozilla" # For some reason, telegram tries to find mozilla where dbus(?) sees firefox running
        ] ++ common_binds ++ data_binds;
      })

      # signal
      (lib.bwrapIt {
        name = "signal-desktop";
        package = signal-desktop;
        net = true;
        binds = [
          {
            from = "~/bwrap/signal";
            to = "~/";
          }
        ] ++ common_binds;
      })

      # thunderbird
      (lib.bwrapIt {
        name = "thunderbird";
        args = "-no-remote";
        package = thunderbird-wayland;
        net = true;
        binds = [
          {
            from = "~/bwrap/thunderbird";
            to = "~/";
          }
        ];
      })

      ##########
      # UNFREE #
      ##########

      # discord
      (lib.bwrapIt {
        name = "discord";
        package = (pkgs.discord.override { nss = nss_latest; });
        net = true;
        binds = [
          {
            from = "~/bwrap/discord";
            to = "~/";
          }
        ] ++ common_binds ++ data_binds;
      })

      # postman
      (lib.bwrapIt {
        name = "postman";
        package = postman;
        net = true;
        binds = [
          {
            from = "~/bwrap/postman";
            to = "~/";
          }
        ] ++ code_binds;
      })

      # insomnia
      (lib.bwrapIt {
        name = "insomnia";
        package = pkgs_unstable.insomnia;
        net = true;
        binds = [
          {
            from = "~/bwrap/insomnia";
            to = "~/";
          }
        ];
      })

      # android-studio
      (lib.bwrapIt {
        name = "android-studio";
        package = android-studio;
        xdg = true;
        binds = [
          {
            from = "~/bwrap/android";
            to = "~/";
          }
        ] ++ code_binds;
      })

      # minecraft
      #(lib.bwrapIt {
      #  name = "minecraft-launcher";
      #  package = minecraft;
      #  #xdg = true;
      #  binds = [
      #    {
      #      from = "~/bwrap/minecraft";
      #      to = "~/";
      #    }
      #  ];
      #})

      # wine
      (lib.bwrapIt {
        name = "wine";
        #package = wineWowPackages.waylandFull;
        package = wineWowPackages.full;
        args = "$@";
        dri = true;
        binds = [
          {
            from = "~/bwrap/wine";
            to = "~/.wine";
          }
        ] ++ game_binds;
      })

      # lutris
      (lib.bwrapIt {
        name = "lutris";
        args = "$@";
        package = lutris.override {
          extraPkgs = pkgs: [ openssl ];
          # Fixes: dxvk::DxvkError
          extraLibraries = pkgs:
            let
              gl = config.hardware.opengl;
            in
            [
              libjson # FIX: samba json errors
              gl.package
              gl.package32
            ] ++ gl.extraPackages ++ gl.extraPackages32;
        };
        dev_bind = true; # required for vulkan
        binds = [
          {
            from = "~/bwrap/lutris";
            to = "~/";
          }
        ];
      })

      # steam
      (lib.bwrapIt {
        name = "steam";
        package = pkgs.steam.override {
          runtimeOnly = true;
          extraPkgs = pkgs: [ ];
          # Fixes: dxvk::DxvkError
          extraLibraries = pkgs: with config.hardware.opengl;
            if pkgs.hostPlatform.is64bit
            then [ package ] ++ extraPackages
            else [ package32 ] ++ extraPackages32;
        };
        dev_bind = true; # required for vulkan
        net = true;
        binds = [
          {
            from = "~/bwrap/steam";
            to = "~/";
          }
        ] ++ common_binds ++ game_binds;
        custom_config = [
          "--setenv QT_QPA_PLATFORM xcb"
          "--setenv SDL_VIDEODRIVER x11"
          #"--setenv LD_PRELOAD ${pkgs.SDL}/lib/libSDL.so:${pkgs32.SDL}/lib/libSDL.so:${pkgs.SDL2}/lib/libSDL2.so:${pkgs32.SDL2}/lib/libSDL2.so"
          "--setenv STEAM_EXTRA_COMPAT_TOOLS_PATHS ${
            stdenv.mkDerivation rec {
              pname = "proton-ge-custom";
              version = "GE-Proton7-29";

              src = fetchurl {
                url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}.tar.gz";
                sha256 = "sha256-bmi3l8FXpoIdBAp8HisXJ1awNxNFzK+XiVwhBN/jOUY=";
              };

              buildCommand = ''
                mkdir -p $out
                tar -C $out --strip=1 -x -f $src
              '';
            }
          }"
        ];
      })
    ];
}
