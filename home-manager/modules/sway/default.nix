{ lib, pkgs, pkgs_unstable, ... }@inputs:

{
  xdg.configFile."sway/lockscreen".source = ./lockscreen.png;
  xdg.configFile."sway/wallpaper".source = ./wallpapers/wallpaper-hax.jpg;

  home.packages = with pkgs; [
    swaybg
    swaylock
    waybar
    wofi # menu
    wf-recorder
    wl-clipboard
    grim # screenshot
    jq # to process json of current monitor
    slurp # select region for screenshot
    mako # notification daemon
    imv
    # make sure the default gnome icons are avaliable (for gtk and tray)
    gnome.adwaita-icon-theme
    networkmanagerapplet # needs to be installed to have the systrey icon of nm-applet
    xorg.xrandr
  ];

  # NOTE: 
  # - For swaylock to work, security.pam is configured on the system config
  wayland.windowManager.sway = {
    enable = true;
    # NOTE: This is a "indirect" Systemd integration
    # usefull to make xdg.portal... work
    # https://github.com/swaywm/sway/issues/5160#issuecomment-641173221
    # https://nixos.wiki/wiki/Sway#Systemd_integration
    systemdIntegration = true;
    wrapperFeatures.gtk = true;
    xwayland = true;
    config =
      let
        out_mid = "HDMI-A-1";
        out_right = "HDMI-A-2";
        out_left = "DP-1";
        out_vr = "DP-2";
      in
      rec {

        ##########
        # INPUTS #
        ##########

        # You can get the names of your inputs by running: swaymsg -t get_inputs
        # Read `man 5 sway-input` for more information about this section.
        input = {
          "type:keyboard" = {
            xkb_layout = "us";
            xkb_variant = "intl";
            #repeat_rate = "50";
            #repeat_delay = "150";
            xkb_options = "lv3:ralt_switch"; # to switch to the 3 level
          };
          "type:mouse" = {
            accel_profile = "flat";
            pointer_accel = "1";
          };
          "type:touchpad" = {
            tap = "enabled";
            pointer_accel = "1";
          };
          # Huion Tablet
          # FIXME: https://github.com/DIGImend/digimend-kernel-drivers/issues/626
          # WORKAROUND: Trigger the bug before login
          #"9580:109:HUION_Huion_Tablet_HS611_Pad" = {
          #  map_to_output = out_mid;
          #};
          "9580:109:HUION_Huion_Tablet_HS611" = {
            map_to_output = out_mid;
          };
        };

        ##########
        # DESIGN #
        ##########

        #fonts = {
        #  names = [ "Inter Nerd Font" ];
        #  size = 10.0;
        #};
        gaps = {
          smartGaps = false;
          inner = 4;
          outer = 0;
          top = 0;
        };
        # output = { "*" = { bg = "~/.background fill"; }; };
        window = {
          border = 2;
          hideEdgeBorders = "none";
        };
        colors =
          {
            focused = {
              #border = "#002b33d0";
              border = "#798BC7";
              background = "#285577";
              text = "#ffffff";
              indicator = "#2e9ef4";
              #childBorder = "#002b33d0";
              childBorder = "#798BC7";
            };
            focusedInactive = {
              border = "#FFFFFF00";
              background = "#5f676a";
              text = "#ffffff";
              indicator = "#484e50";
              childBorder = "#FFFFFF00";
            };
            unfocused = {
              border = "#FFFFFF00";
              background = "#222222";
              text = "#888888";
              indicator = "#292d2e";
              childBorder = "#FFFFFF00";
            };
            urgent = {
              border = "#FFFFFF00";
              background = "#900000";
              text = "#ffffff";
              indicator = "#900000";
              childBorder = "#FFFFFF00";
            };
            background = "#ffffff";
          };

        ############
        # BINDINGS #
        ############

        modifier = "Mod4"; # Mod1 -> alt | Mod4 -> Super
        menu = "zsh -ic 'wofi --show drun,run --lines 12 --prompt \"\" --allow-images --hide-scroll --no-actions --insensitive | xargs swaymsg exec --'";
        terminal = "kitty";
        modes = {
          disabled = {
            "${modifier}+Shift+d" = "mode default";
          };
          resize = {
            "${modifier}+Left" = "resize shrink width 10px";
            "${modifier}+Down" = "resize grow height 10px";
            "${modifier}+Up" = "resize shrink height 10px";
            "${modifier}+Right" = "resize grow width 10px";

            # return to default mode
            "${modifier}+Return" = "mode default";
            "${modifier}+Escape" = "mode default";
          };
        };
        keybindings = {
          # common - 1/top
          "${modifier}+Shift+q" = "kill";
          "${modifier}+Shift+d" = "mode disabled";
          "${modifier}+d" = "exec ${menu}";
          "${modifier}+Shift+r" = "reload; output ${out_left} transform 270";
          "${modifier}+Return" = "exec ${terminal}";
          # window toggles - 1/bottom
          "${modifier}+z" = "fullscreen";
          "${modifier}+x" = "floating toggle";
          "${modifier}+m" = "focus mode_toggle";
          "${modifier}+v" = "focus parent";
          # dangerous - 2/bottom
          "${modifier}+Shift+k" = "swaynag -t warning -m 'Power Menu Options' -b 'Logout' 'swaymsg exit' -b 'Restart' 'shutdown -r now' -b 'Shutdown'  'shutdown -h now' --background=#002b33DD --button-background=#0077b3DD --button-text=#FFFFFF --button-border-size=0 --text=#FFFFFF --border-bottom-size=0 --button-margin-right=10";
          "${modifier}+Shift+l" = "exec 'swaylock -f -i ~/.config/sway/lockscreen'";
          # Working with the focused windows
          #
          # Layout stuff - 1/mid
          #
          # You can "split" the current object of your focus with
          "${modifier}+a" = "splith";
          "${modifier}+s" = "splitv";
          "${modifier}+h" = "layout stacking";
          "${modifier}+t" = "layout tabbed";
          "${modifier}+g" = "layout toggle split";
          "${modifier}+Shift+g" = "mode resize";
          #
          # Moving around - 2/mid
          #
          # Move your focus around
          "${modifier}+Left" = "focus left";
          "${modifier}+Down" = "focus down";
          "${modifier}+Up" = "focus up";
          "${modifier}+Right" = "focus right";
          "${modifier}+n" = "focus left";
          "${modifier}+e" = "focus down";
          "${modifier}+o" = "focus up";
          "${modifier}+i" = "focus right";
          # Move the focused window
          "${modifier}+Shift+Left" = "move left";
          "${modifier}+Shift+Down" = "move down";
          "${modifier}+Shift+Up" = "move up";
          "${modifier}+Shift+Right" = "move right";
          "${modifier}+Shift+n" = "move left";
          "${modifier}+Shift+e" = "move down";
          "${modifier}+Shift+o" = "move up";
          "${modifier}+Shift+i" = "move right";
          # Move to scratchpad
          # Sway has a "scratchpad", which is a bag of holding for windows.
          # You can send windows there and get them back later.
          "${modifier}+y" = "move scratchpad";
          # Show the next scratchpad window or hide the focused scratchpad window.
          # If there are multiple scratchpad windows, this command cycles through them.
          "${modifier}+Shift+y" = "scratchpad show";
          #
          # Gaming - 2/top
          #
          # see with: swaymsg -t get_outputs
          # man 5 sway-input
          # start on 1080/1400 extends a fullHD size 1920/1080
          "${modifier}+Shift+j" = "input 1241:64605:USB_Gaming_Mouse map_to_region 1080 1400 1920 1080";
          "${modifier}+Shift+f" = "input 1241:64605:USB_Gaming_Mouse map_to_region 0 0 4920 2480";
          # fix wine not finding mouse https://github.com/swaywm/sway/issues/4857
          # maybe its necessary to turn off monitors
          "${modifier}+Shift+u" = "${out_mid} resolution 1920x1080 position 0 0; output $out-left position 4920 1400";
          #
          # Misc - 2/top
          #
          # screenshot
          "${modifier}+p" = "exec grim -t png -l 9 -o $(swaymsg -t get_outputs -r | jq -r '.[] | select(.focused == true) | .name') - > ~/screenshot.png";

          ##############
          # WORKSPACES #
          ##############

          "${modifier}+1" = "workspace 1";
          "${modifier}+2" = "workspace 2";
          "${modifier}+3" = "workspace 3";
          "${modifier}+4" = "workspace 4";
          "${modifier}+5" = "workspace 5";
          "${modifier}+6" = "workspace 6";
          "${modifier}+7" = "workspace 7";
          "${modifier}+8" = "workspace 8";
          "${modifier}+9" = "workspace 9";
          "${modifier}+0" = "workspace 10";
          "${modifier}+Ctrl+1" = "workspace 11:";
          "${modifier}+Ctrl+2" = "workspace 12:";
          "${modifier}+Ctrl+3" = "workspace 13:d";
          "${modifier}+Shift+1" = "move container to workspace 1";
          "${modifier}+Shift+2" = "move container to workspace 2";
          "${modifier}+Shift+3" = "move container to workspace 3";
          "${modifier}+Shift+4" = "move container to workspace 4";
          "${modifier}+Shift+5" = "move container to workspace 5";
          "${modifier}+Shift+6" = "move container to workspace 6";
          "${modifier}+Shift+7" = "move container to workspace 7";
          "${modifier}+Shift+8" = "move container to workspace 8";
          "${modifier}+Shift+9" = "move container to workspace 9";
          "${modifier}+Shift+0" = "move container to workspace 10";
          "${modifier}+Ctrl+0" = "move container to workspace vr";
        };
        workspaceAutoBackAndForth = true;
        workspaceOutputAssign = [
          { workspace = "1"; output = out_mid; }
          { workspace = "3"; output = out_mid; }
          { workspace = "5"; output = out_mid; }
          { workspace = "7"; output = out_mid; }
          { workspace = "9"; output = out_mid; }
          { workspace = "2"; output = out_right; }
          { workspace = "4"; output = out_right; }
          { workspace = "6"; output = out_right; }
          { workspace = "8"; output = out_right; }
          { workspace = "10"; output = out_right; }
          { workspace = "11:"; output = out_mid; }
          { workspace = "12:"; output = out_right; }
          { workspace = "13:d"; output = out_left; }
          { workspace = "vr"; output = out_vr; }
        ];

        ###########
        # STARTUP #
        ###########

        startup = [
          # To ask for sudo via dbus
          #{ command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"; }
          { command = "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"; }
          #
          # Rotations and Positions
          #
          { command = "swaymsg 'output ${out_mid} position 0 0'"; always = true; }
          { command = "swaymsg 'output ${out_right} position 1920 0'"; always = true; }
          # Its at the right because games try to open on the resolution of monitors at 0x0
          # causing lots of bugs for both native and wine games, and breaking xrandr primary monitor
          { command = "swaymsg 'output ${out_left} mode 2560x1080@60hz'"; always = true; }
          { command = "swaymsg 'output ${out_left} transform 270'"; always = true; }
          { command = "swaymsg 'output ${out_left} position 3840 0'"; always = true; } # 2560v x 1080h
          { command = "swaymsg 'output ${out_vr} position 4920 0'"; always = true; }
          # xrandr set
          { command = "${pkgs.xorg.xrandr}/bin/xrandr --output $(${pkgs.xorg.xrandr}/bin/xrandr | awk '/1920x1080/ {print $1}' | head -n 1) --primary"; always = true; }
          #
          # Programs
          #
          { command = "${pkgs.mako}/bin/mako"; }
          { command = "${pkgs.swaybg}/bin/swaybg -i ~/.config/sway/wallpaper -m fill"; }
          # swaymsg sets the mouse in the right place ;)
          { command = "swaymsg 'workspace 11:; exec firefox'"; }
          { command = "swaymsg 'workspace 12:; exec telegram-desktop'"; }
          { command = "swaymsg 'workspace 13:d; exec ${terminal} btm --color gruvbox; layout toggle split; exec discord'"; }
        ];
      };
  };
}
