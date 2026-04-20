# Development tools: Python, uv. Enable via userSettings.development.enable.
{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings.development;
in
{
  options.userSettings.development = {
    enable = lib.mkEnableOption "Development tools (Python, uv)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # Languages and Libraries
      python3
      uv

      # Other
      opencode
    ];

    # OpenCode (anomalyco) global config: ~/.config/opencode/opencode.json
    xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      provider = {
        "llama.cpp" = {
          npm = "@ai-sdk/openai-compatible";
          name = "llama-server (local)";
          options = {
            baseURL = "http://127.0.0.1:3420/v1";
          };
          models = {
            "Qwen3.5-35B-A3B-UD-Q4_K_XL.gguf" = {
              name = "Qwen3.5-35B-A3B (local)";
            };
          };
        };
      };
      model = "llama.cpp/Qwen3.5-35B-A3B-UD-Q4_K_XL.gguf";
      mcp = {
        cognee = {
          type = "remote";
          url = "http://localhost:3441/sse";
          enabled = true;
        };
      };
    };
  };
}
