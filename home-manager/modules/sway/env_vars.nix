{ lib, pkgs, pkgs_unstable, ... }@inputs:

{
  home.sessionVariables = {
    # The Clutter toolkit has a Wayland backend that allows it to run as a Wayland client. The backend is enabled in the clutter package.
    # To run a Clutter application on Wayland, set CLUTTER_BACKEND=wayland.
    CLUTTER_BACKEND = "wayland";
    XDG_SESSION_TYPE = "wayland";

    # NEEDS: qt5-wayland
    # To run a Qt 5 application with the Wayland plugin [3], use -platform wayland or QT_QPA_PLATFORM=wayland environment variable. To force the usage of X11 on a Wayland session, use QT_QPA_PLATFORM=xcb. This might be necessary for some proprietary applications that do not use the system's implementation of Qt, such as zoomAUR.
    # if you are using NVIDIA maybe use https://github.com/NVIDIA/egl-wayland/
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_FORCE_DPI = "physical";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

    # NEEDS: qt5ct
    # On some compositors, for example sway, Qt applications running natively might have missing functionality. For example, KeepassXC will be unable to minimize to tray. This can be solved by installing qt5ct and setting QT_QPA_PLATFORMTHEME=qt5ct before running the application.
    QT_QPA_PLATFORMTHEME = "qt5ct";

    # To run a SDL2 application on Wayland, set SDL_VIDEODRIVER=wayland
    # WARNING: Many proprietary games come bundled with old versions of SDL, which don't support Wayland and might break entirely if you set SDL_VIDEODRIVER=wayland. To force the application to run with XWayland, set SDL_VIDEODRIVER=x11.
    SDL_VIDEODRIVER = "wayland";

    # https://github.com/swaywm/sway/issues/595
    # https://wiki.archlinux.org/title/Java#Gray_window,_applications_not_resizing_with_WM,_menus_immediately_closing
    _JAVA_AWT_WM_NONREPARENTING = "1";

    # https://wiki.archlinux.org/title/Java#Better_font_rendering
    AWT_TOOLKIT = "MToolkit";
    _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true";
    JDK_JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true";

    # More recent versions of Firefox support opting into Wayland via an environment variable
    # MOZ_ENABLE_WAYLAND=1
    # MOZ_WEBRENDER=1
    # ?
    # GDK_BACKEND="wayland"
  };
}
