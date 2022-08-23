{ lib, pkgs, ... }:

with builtins;
with lib;

# NOTES:
# dev-bind /dev/dri - for GPU acceleration
# bind /bin - for using xdg-open (eg: telegram)

{
  # options:
  # - name: string
  # - args: string | nil
  # - package: string
  # - exec: string
  # - binds: [string] | [{from: string; to: string;}]
  # - xdg: boolean | nil
  # - dri: boolean | nil
  # - net: boolean | nil
  # - dev_bind: boolean | nil                          # FOR VULKAN SUPPORT
  # - share: boolean | nil
  # - custom_config: [string] | nil
  bwrapIt = (set:
    let
      raw_binds = map (x: if x ? to && x ? from then x else { to = x; from = x; }) set.binds;

      # bind arguments to bwrap
      binds_list = map (x: "--bind-try ${x.from} ${x.to}") raw_binds;
      binds = concatStringsSep " " binds_list;

      # mkdir -p (only if bwrap is on the name)
      mkdir_list = map
        (x:
          if isList (match ".*(bwrap).*" x.from) then
            "mkdir -p ${x.from}\n"
          else
            ""
        )
        raw_binds;
      mkdir = concatStringsSep "" mkdir_list;

      xdg =
        if set ? xdg && set.xdg then
          "--bind $XDG_RUNTIME_DIR $XDG_RUNTIME_DIR" else "";

      dev_or_dri =
        if (set ? dri && set.dri) || (set ? dev_bind && set.dev_bind) then
          (if set ? dev_bind && set.dev_bind then
            "--dev-bind /dev /dev"
          else
            "--dev-bind /dev/dri /dev/dri")
        else "";

      net =
        if set ? net && set.net then
          "--share-net" else "";

      custom_config =
        if set ? custom_config then
          concatStringsSep " " set.custom_config
        else "";

      args = if set ? args then set.args else "";

      exec = if set ? exec then set.exec else "bin/${set.name}";

      share = if set ? share then "" else "--unshare-all";
    in
    #--unshare-user --unshare-pid --unshare-uts --unshare-cgroup-try \
    pkgs.writeScriptBin set.name ''
      #!${pkgs.stdenv.shell}
      ${mkdir}
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
        --new-session \
        ${share} ${net} ${dev_or_dri} ${xdg} ${binds} ${custom_config} ${lib.getBin set.package}/${exec} ${args}
    '');
}
