{ inputs
, pkgs
, lib ? inputs.nixpkgs_stable.lib
, hm_lib ? inputs.home_manager.lib
, ...
}:

with builtins;
with lib;

lib.makeExtensible (self:
  let
    result = pipe ./. [
      filesystem.listFilesRecursive
      (filter (file: hasSuffix ".nix" file && file != ./default.nix))
      (map (file: import file { inherit pkgs inputs; lib = self; }))
      (foldr recursiveUpdate { })
    ];
  in
  { hm = hm_lib.hm // result; } // lib // result
)
