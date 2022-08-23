# TUTORIALS:
# https://msucharski.eu/posts/application-isolation-nixos-containers/
# https://discourse.nixos.org/t/use-home-manager-inside-a-nixos-container-flakes/17850

#
# USAGE:
#
# This is a poc using containers to run steam
#
# - after importing this config you just need to add its binary
# ```
# environment.systemPackages = with pkgs; [
#   (pkgs.writeScriptBin "steam-launcher" ''
#     #!${pkgs.stdenv.shell}
#     set -euo pipefail

#     if [[ "$(systemctl is-active container@steam.service)" != "active" ]]; then
#       systemctl start container@steam.service
#     fi

#     exec machinectl shell shiryel@steam /usr/bin/env bash --login -c "exec steam"
#   '')
# ];
# ```
#
# - Also, you can test the container using the following commands:
# systemctl start container@steam.service
# machinectl shell shiryel@steam

{ lib, pkgs, pkgs_unstable, home_manager, ... }@inputs:

{
  containers.steam =
    let
      hostCfg = import ../system_wide/intel.nix inputs;
      userName = "nali";
      userUid = "1000";
    in
    {
      bindMounts = {
        steamHome = rec {
          hostPath = "/home/${userName}/.steam";
          mountPoint = hostPath;
          isReadOnly = false;
        };
        steamGames = rec {
          hostPath = "/home/${userName}/.local/share/Steam";
          mountPoint = hostPath;
          isReadOnly = false;
        };
        waylandDisplay = rec {
          hostPath = "/run/user/${toString userUid}";
          mountPoint = hostPath;
          isReadOnly = true;
        };
        # Only when running x11 applications in the guest
        x11Display = rec {
          hostPath = "/tmp/.X11-unix";
          mountPoint = hostPath;
          isReadOnly = true;
        };
      };

      config = {
        imports = [
          home_manager
          ../system_wide/amd.nix
          #../system_wide/fonts.nix
        ];
        nixpkgs.pkgs = pkgs;

        users.users."${userName}" = {
          uid = 1000;
          isNormalUser = true;
          #initialPassword = "secret";
          extraGroups = lib.mkForce [ ];
        };

        hardware.opengl = {
          enable = true;
          extraPackages = hostCfg.hardware.opengl.extraPackages;
        };

        home-manager = {
          useGlobalPkgs = true;
          users."${userName}" = {
            programs.bash.enable = true;

            #wayland.windowManager.sway = {
            #  enable = true;
            #  wrapperFeatures.gtk = true;
            #  config = {
            #    window.titlebar = true;
            #  };
            #};
            #gtk.enable = true;

            home.packages = with pkgs; [
              (steam.override {
                runtimeOnly = false;
                #extraPkgs = pkgs: [
                #];
                extraLibraries = pkgs: [
                  # Worms W.M.D deps
                  # also take a look at: 
                  # https://steamcommunity.com/app/327030/discussions/2/1754645842396386245/
                  curl
                  wavpack
                  # Steam
                  #amdvlk
                  #driversi686Linux.amdvlk
                ];
              })
            ];

            home.sessionVariables = {
              # Envs to connect with the main process
              WAYLAND_DISPLAY = "wayland-1";
              XDG_RUNTIME_DIR = "/run/user/${toString userUid}";
              DISPLAY = ":0";
              # General config (explanaition on shiryel's .zprofile)
              CLUTTER_BACKEND = "wayland";
              XDG_SESSION_TYPE = "wayland";
              QT_QPA_PLATFORM = "xcb";
              QT_WAYLAND_FORCE_DPI = "physical";
              QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
              QT_QPA_PLATFORMTHEME = "qt5ct";
              SDL_VIDEODRIVER = "x11";
              _JAVA_AWT_WM_NONREPARENTING = "1";
              AWT_TOOLKIT = "MToolkit";
              _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true";
              JDK_JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true";
            };
          };
        };

        systemd.services.fix-nix-dirs =
          let
            profileDir = "/nix/var/nix/profiles/per-user/${userName}";
            gcrootsDir = "/nix/var/nix/gcroots/per-user/${userName}";
          in
          {
            script = ''
              #!${pkgs.stdenv.shell}
              set -euo pipefail

              mkdir -p ${profileDir} ${gcrootsDir}
              chown ${userName}:root ${profileDir} ${gcrootsDir}
            '';
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
              Type = "oneshot";
            };
          };

        systemd.services.fix-run-permission = {
          script = ''
            #!${pkgs.stdenv.shell}
            set -euo pipefail

            chown ${userName}:users /run/user/${toString userUid}
            chmod u=rwx /run/user/${toString userUid}
          '';
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
          };
        };
      };
    };
}
