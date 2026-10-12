# Development tools: Python, uv. Enable via userSettings.development.enable.
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.userSettings.development;
in
{
  # pi.nix provides the pi binary and declarative extension wiring.
  # Imported unconditionally: its config is gated by its own enable option,
  # which we only set when development is enabled (imports may not depend
  # on final config).
  imports = [
    inputs.pi.homeModules.default
  ];

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

    # Home-manager's pi module would install a second pi binary; pi.nix
    # (programs.pi.coding-agent below) provides the one we use. This block
    # only owns ~/.pi/agent/models.json.
    programs.pi-coding-agent = {
      enable = true;
      package = null;

      # Home-manager owns ~/.pi/agent/models.json from this block (was a
      # hand-written file; backup kept as models.json.bak next to it).
      models = {
        providers.llamacpp = {
          baseUrl = "http://localhost:3420/v1";
          api = "openai-completions";
          apiKey = "local-not-needed";
          compat = {
            supportsDeveloperRole = false;
            supportsStore = false;
            supportsReasoningEffort = false;
            maxTokensField = "max_tokens";
            thinkingFormat = "chat-template";
            chatTemplateKwargs = {
              enable_thinking = { "$var" = "thinking.enabled"; };
              reasoning_effort = { "$var" = "thinking.effort"; omitWhenOff = true; };
              preserve_thinking = true;
            };
          };
          models = [
            {
              id = "qwen3.8-27b";
              name = "Qwen3.8 27B (local llama.cpp)";
              reasoning = true;
              thinkingLevelMap = {
                minimal = "low";
                low = "low";
                medium = "medium";
                high = "xhigh";
                xhigh = "xhigh";
                max = null;
              };
              input = [ "text" ];
              contextWindow = 131072;
              maxTokens = 32768;
              samplingParams = {
                temperature = 0.6;
                top_p = 0.95;
                top_k = 20;
                min_p = 0.0;
              };
              cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
            }
          ];
        };
        # NInfer (docker/localai, port 3422): same Qwen3.8-27B weights as NVFP4,
        # separate model id so pi can pick the engine. Thinking control rides
        # chat_template_kwargs, which the NInfer Qwen template accepts
        # (enable_thinking / reasoning_effort / preserve_thinking).
        providers.ninfer = {
          baseUrl = "http://localhost:3422/v1";
          api = "openai-completions";
          apiKey = "local-not-needed";
          compat = {
            supportsDeveloperRole = false;
            supportsStore = false;
            supportsReasoningEffort = false;
            maxTokensField = "max_tokens";
            thinkingFormat = "chat-template";
            chatTemplateKwargs = {
              enable_thinking = { "$var" = "thinking.enabled"; };
              reasoning_effort = { "$var" = "thinking.effort"; omitWhenOff = true; };
              preserve_thinking = true;
            };
          };
          models = [
            {
              id = "qwen3.8-27b-ninfer";
              name = "Qwen3.8 27B (local NInfer)";
              reasoning = true;
              thinkingLevelMap = {
                minimal = "low";
                low = "low";
                medium = "medium";
                high = "xhigh";
                xhigh = "xhigh";
                max = null;
              };
              input = [ "text" "image" ];
              contextWindow = 240000;
              maxTokens = 32768;
              samplingParams = {
                temperature = 0.6;
                top_p = 0.95;
                top_k = 20;
                min_p = 0.0;
              };
              cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
            }
          ];
        };
      };
    };

    # pi.nix (inputs.pi): provides the pi binary and passes `extensions` as
    # --extension flags on every invocation. Specs match settings.json's
    # `packages`; pi dedupes by package name and reconciles the npm
    # packages under ~/.pi/agent/npm.
    programs.pi.coding-agent = {
      enable = true;
      extensions = [
        "npm:@gotgenes/pi-permission-system"
        "npm:pi-web-access"
        "npm:pi-hermes-memory"
        "npm:pi-lens"
        "npm:@juicesharp/rpiv-todo"
        "npm:@juicesharp/rpiv-ask-user-question"
        "npm:pi-subagents"
      ];
    };
  };
}
