# Toggle and list packages to take from ~/repos/nixpkgs-dev (local nixpkgs clone).
# Set enable = true to use your dev versions until the PR is merged; then set back to false.
{
  enable = true;
  packageNames = [
    "deadlock-mod-manager"
  ];
}
