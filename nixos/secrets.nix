let
  alex = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICUe5G6o++8ueJzhj/vuD3phcdtQi2Mz4ReIol4sAEyw ahernandezjr0@gmail.com";
  desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILIrHGo7Rg6yJIypDjJS4XzHGabX/NEeekdEFNaWC81V root@desktop";
in
{
  "secrets/syncthing-password.age".publicKeys = [ alex desktop ];
  "secrets/syncthing-user.age".publicKeys = [ alex desktop ];
}
