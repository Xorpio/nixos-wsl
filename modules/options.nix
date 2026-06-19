{ lib, ... }:
{
  options.my = {
    nixosModules = lib.mkOption {
      type        = lib.types.attrsOf lib.types.deferredModule;
      default     = {};
      description = "Named NixOS modules assembled by feature files.";
    };
    homeModules = lib.mkOption {
      type        = lib.types.attrsOf lib.types.deferredModule;
      default     = {};
      description = "Named home-manager modules assembled by feature files.";
    };
  };
}
