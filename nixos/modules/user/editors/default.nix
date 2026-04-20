{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.userSettings.editors;
  # Stub ftplugins so nvf's LSP configs (ts_ls, qmlls) don't trigger "Unknown filetype" warnings.
  nvfFiletypeStubs = pkgs.runCommand "nvf-ftplugin-stubs" { } ''
    mkdir -p $out/ftplugin
    echo "\" Stub so filetype is known (nvf LSP)" > $out/ftplugin/qmljs.vim
    echo "\" Stub so filetype is known (nvf LSP)" > $out/ftplugin/javascript.jsx.vim
    echo "\" Stub so filetype is known (nvf LSP)" > $out/ftplugin/typescript.tsx.vim
  '';
in
{
  options.userSettings.editors = {
    enable = lib.mkEnableOption "Editors (Cursor, VSCode, Neovim) and their plugins";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # Editors
      vscode
      code-cursor

      # Env Manager
      devenv

      # LSPs
      pyright
      typescript-language-server
      omnisharp-roslyn
    ];

    programs.vscode = {
      enable = true;
    };

    programs.nvf = {
      enable = true;
      settings = {
        vim = {
          viAlias = true;
          vimAlias = true;
          options.clipboard = "unnamedplus";
          clipboard.providers.wl-copy = {
            enable = true;
            package = null;
          };
          extraPackages = with pkgs; [ qt6.qtdeclarative ];
          startPlugins = [
            "plenary-nvim"
            "telescope"
            "nvim-treesitter"
            "nvim-lspconfig"
            "which-key-nvim"
            "mini-icons"
            "nvim-web-devicons"
          ];
          extraPlugins = with pkgs.vimPlugins; {
            vim-nix = {
              package = vim-nix;
            };
          };
          additionalRuntimePaths = [ nvfFiletypeStubs ];
          lsp = {
            enable = true;
          };
          languages = {
            nix.enable = true;
            python = {
              enable = true;
              lsp = { servers = [ "pyright" ]; };
            };
            csharp = {
              enable = true;
              lsp = { servers = [ "omnisharp" ]; };
            };
            ts.enable = true;
            qml.enable = true;
          };
        };
      };
    };
  };
}


