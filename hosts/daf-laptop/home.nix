{ pkgs, config, ... }:
{
  home.username = "daf";
  home.homeDirectory = "/home/daf";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  sops.defaultSopsFile = ../../secrets/machines/daf-laptop/taskwarrior.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/daf/.config/sops/age/keys.txt";
  sops.secrets."sync.server.url" = { };
  sops.secrets."sync.server.client_id" = { };
  sops.secrets."sync.encryption_secret" = { };

  home.packages = with pkgs; [
    tasksh
    taskwarrior-tui
  ];

  programs.taskwarrior = {
    enable = true;
    package = pkgs.taskwarrior3;
    config = {
      dateformat         = "Y-M-D H:N";
      "dateformat.info"  = "Y-M-D H:N:S";
      "dateformat.annotation" = "Y-M-D H:N";
    };
  };

  home.activation.generateTaskrc = config.lib.dag.entryAfter ["writeBoundary"] ''
    ${pkgs.bash}/bin/bash << 'EOF'
      mkdir -p ~/.config/taskwarrior 2>/dev/null || true
      cat > ~/.taskrc << TASKRC
# Taskwarrior configuration with synced settings
dateformat=Y-M-D H:N
dateformat.info=Y-M-D H:N:S
dateformat.annotation=Y-M-D H:N

# Sync configuration (populated from secrets)
sync.server.url=$(cat "${config.sops.secrets."sync.server.url".path}")
sync.server.client_id=$(cat "${config.sops.secrets."sync.server.client_id".path}")
sync.encryption_secret=$(cat "${config.sops.secrets."sync.encryption_secret".path}")
TASKRC
      chmod 600 ~/.taskrc
    EOF
  '';

  # rebuild / hm → both trigger nixos-rebuild (HM is managed at system level;
  #                Nix caches mean a home-only change is still fast)
  home.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --impure --flake ~/nixos-wsl#daf-laptop";
    hm      = "sudo nixos-rebuild switch --impure --flake ~/nixos-wsl#daf-laptop";
  };

  programs.zsh = {
    enable = true;
    autocd = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      share = true;
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;

      format = ''
        $username\
        $hostname\
        $localip\
        $shlvl\
        $singularity\
        $kubernetes\
        $directory\
        $vcsh\
        $fossil_branch\
        $git_branch\
        $git_commit\
        $git_state\
        $git_metrics\
        $git_status\
        $hg_branch\
        $pijul_channel\
        $docker_context\
        $dotnet\
        $elixir\
        $elm\
        $erlang\
        $fennel\
        $golang\
        $guix_shell\
        $haskell\
        $haxe\
        $helm\
        $java\
        $julia\
        $kotlin\
        $gradle\
        $lua\
        $nim\
        $nix_shell\
        $ocaml\
        $opa\
        $perl\
        $php\
        $pulumi\
        $purescript\
        $python\
        $raku\
        $rlang\
        $red\
        $ruby\
        $rust\
        $scala\
        $solidity\
        $spack\
        $swift\
        $terraform\
        $vlang\
        $vagrant\
        $zig\
        $nats\
        $buf\
        $cmake\
        $cobol\
        $daml\
        $direnv\
        $flox\
        $gcloud\
        $gleam\
        $glsl\
        $gnuplot\
        $meson\
        $move\
        $nasm\
        $nixos_shell\
        $nwc\
        $odin\
        $OpenStack\
        $os\
        $package\
        $paket\
        $pkgconfig\
        $prisma\
        $quarto\
        $rescript\
        $shaderc\
        $typst\
        $unisonlang\
        $unox\
        $vlang\
        $vala\
        $verilog\
        $verifpal\
        $wasm\
        $wasmer\
        $zig\
        $conda\
        $meson\
        $sbt\
        $status\
        $container\
        $shell\
        $character
      '';
    };
  };
}
