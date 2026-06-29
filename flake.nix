{
  description = "NixOS WSL — minimal bootstrap";

  inputs = {
    flake-parts.url      = "github:hercules-ci/flake-parts";
    nixpkgs.url          = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-wsl = {
      url    = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url    = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url    = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    sops-nix = {
      url    = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url    = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url    = "github:noctalia-dev/noctalia/legacy-v4";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    claude-desktop = {
      url    = "github:aaddrick/claude-desktop-debian";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    paseo = {
      url = "github:getpaseo/paseo";
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" ];

    imports = [
      ./modules/options.nix
      ./modules/features/shell.nix
      ./modules/features/chats.nix
      ./modules/features/git.nix
      ./modules/features/neovim.nix
      ./modules/features/taskwarrior.nix
      ./modules/features/wsl.nix
      ./modules/features/niri.nix
      ./modules/features/audio.nix
      ./modules/features/nvidia.nix
      ./modules/features/desktop.nix
      ./modules/features/clipboard.nix
      ./modules/features/vscode.nix
      ./modules/features/gaming.nix
      ./modules/features/input.nix
      ./modules/hosts/centric.nix
      ./modules/hosts/daf-laptop.nix
      ./modules/hosts/desktop-pc.nix
      ./modules/hosts/desktop-wsl.nix
    ];
  };
}
