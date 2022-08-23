###########################################################
# This file configures your AMD CPU / GPU
#
# TEST:
# - Verify Vulkan
#   vulkaninfo | grep GPU
#   vulkaninfo | grep DRI
#
# - Verify OpenGL
#   glxinfo | grep OpenGL
#
# - Monitoring your GPU
#   watch -n 0.5 sudo cat /sys/kernel/debug/dri/0/amdgpu_pm_info
#   https://wiki.archlinux.org/title/AMDGPU#Features
#
# - Testing lavapipe (Mesa LLVMPIPE):
#   VK_ICD_FILENAMES=/run/opengl-driver/share/vulkan/icd.d/lvp_icd.x86_64.json vkcube
#
# NOTES:
# - Other packages needs to be using the same version of Vulkan
#   like Steam or vulkaninfo to work properly
#
# DOCS:
# - https://nixos.wiki/wiki/AMD_GPU
# - https://linux-gaming.kwindu.eu/index.php?title=Improving_performance#AMD
# - https://nixos.wiki/wiki/Accelerated_Video_Playback
# - https://wiki.archlinux.org/title/Hardware_video_acceleration#Verification
# - https://en.wikipedia.org/wiki/OpenCL
#
###########################################################

{ config, pkgs, pkgs_unstable, ... }:

{
  hardware = {
    # - CPU security
    cpu.intel.updateMicrocode = true;

    # - Vulkan / OpenGL
    opengl = {
      enable = true;
      # - both dri support required for STEAM
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        # NOTE:
        # Do not add amdvlk, mesa RADV is faster

        ### Hardware video acceleration ###
        # https://trac.ffmpeg.org/wiki/HWAccelIntro

        # https://trac.ffmpeg.org/wiki/Hardware/VAAPI
        # initially developed by Intel but can be used in combination with other devices
        vaapiIntel

        # https://github.com/i-rinat/libvdpau-va-gl
        # VDPAU driver with VA-API/OpenGL backend.
        #libvdpau-va-gl

        ### OpenCL ###
        rocm-opencl-icd
        rocm-opencl-runtime
      ];
      extraPackages32 = with pkgs; [
        driversi686Linux.vaapiIntel
        #driversi686Linux.libvdpau-va-gl
      ];
      #setLdLibraryPath = true;
    };
  };

  # RADV is faster: https://www.phoronix.com/review/radv-amdvlk-mid22
  # NOTE: DO NOT ADD VK_ICD_FILENAMES by default, but you can add it to a game or app to test:
  # VK_ICD_FILENAMES="/run/opengl-driver-32/share/vulkan/icd.d/radeon_icd.i686.json:/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json"
  #environment.variables = {
  #  AMD_VULKAN_ICD = "RADV";
  #};

  # - load the correct driver right away
  boot.initrd.kernelModules = [ "intelgpu" ]; #amdgpu
  services.xserver.videoDrivers = [ "intelgpu" ]; # add "radeon" if old GPU

  environment.systemPackages = with pkgs; [
    # DO NOT INSTALL gpu-burn, will try to install cuda and fail
    #
    glxinfo # glxgears
    vulkan-tools # vulkaninfo
    clinfo
    # vulkan-loader
    # vulkan-headers
    # vulkan-extension-layer
  ];
}
