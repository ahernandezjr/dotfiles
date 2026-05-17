{ pkgs, ... }:

let
  llamaswap = pkgs.writeShellApplication {
    name = "llamaswap";
    runtimeInputs = with pkgs; [ fzf docker-compose coreutils findutils gnused ];
    text = ''
      MODEL_DIR="''${HOME}/.hai/models/llm/gguf"
      DOTFILES_DIR="''${HOME}/dotfiles"
      ENV_FILE="''${DOTFILES_DIR}/docker/localai/.env"

      if [ ! -d "$MODEL_DIR" ]; then
        echo "Error: Model directory $MODEL_DIR not found."
        exit 1
      fi

      # Find models and use fzf to select one
      SELECTED_MODEL=$(find "$MODEL_DIR" -name "*.gguf" -printf "%f\n" | fzf --header "Select a LocalAI model (GGUF)")

      if [ -n "$SELECTED_MODEL" ]; then
        echo "Updating $ENV_FILE with model: $SELECTED_MODEL"
        
        # Create or update the .env file
        if [ -f "$ENV_FILE" ]; then
          sed -i "s/^LOCALAI_MODEL=.*/LOCALAI_MODEL=$SELECTED_MODEL/" "$ENV_FILE"
        else
          echo "LOCALAI_MODEL=$SELECTED_MODEL" > "$ENV_FILE"
        fi

        # Restart LocalAI container
        echo "Restarting LocalAI container..."
        cd "$DOTFILES_DIR/docker/localai"
        docker-compose restart llamacpp cognee cognee-mcp
        echo "Done."
      else
        echo "No model selected. Exiting."
      fi
    '';
  };
in
{
  home.packages = [ llamaswap ];
}
