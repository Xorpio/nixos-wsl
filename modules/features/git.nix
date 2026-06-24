{ ... }:
{
  my.homeModules.git = { lib, config, ... }:
  let cfg = config.my.git; in
  {
    options.my.git = {
      userName = lib.mkOption {
        type    = lib.types.nullOr lib.types.str;
        default = null;
        description = "Git user.name for global config.";
      };
      userEmail = lib.mkOption {
        type    = lib.types.nullOr lib.types.str;
        default = null;
        description = "Git user.email for global config.";
      };
    };

    config = {
      assertions = [{
        assertion = (cfg.userName == null) == (cfg.userEmail == null);
        message   = "Set both my.git.userName and my.git.userEmail, or leave both unset.";
      }];

      programs.git = lib.mkIf (cfg.userName != null) {
        enable = true;
        settings = {
          user.name  = cfg.userName;
          user.email = cfg.userEmail;
          merge.conflictstyle = "zdiff3";
        };
      };
    };
  };
}
