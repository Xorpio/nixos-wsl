{ ... }:
{
  my.homeModules.chats = { pkgs, config, ... }: {
    home.packages = with pkgs; [
      signal-desktop
      whatsapp-electron
    ];
  };
}