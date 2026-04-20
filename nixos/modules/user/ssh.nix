# SSH client + agent for GitHub (git push/fetch). Key stays in ~/.ssh/; create with:
#   ssh-keygen -t ed25519 -C "your-email@example.com"
# Add the public key at GitHub → Settings → SSH and GPG keys.
{ config, lib, ... }:

{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    matchBlocks."github.com" = {
      identityFile = [ "~/.ssh/id_ed25519" ];
      hostname = "github.com";
    };
  };
  services.ssh-agent.enable = true;
}
