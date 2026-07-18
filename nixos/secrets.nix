let
  alex_desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICUe5G6o++8ueJzhj/vuD3phcdtQi2Mz4ReIol4sAEyw ahernandezjr0@gmail.com";
  alex_laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHEchyWdEd4/47h1EpU40Vr5sGC8/L89THzamj1GxLgZ ahernandezjr0@gmail.com";
  desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILIrHGo7Rg6yJIypDjJS4XzHGabX/NEeekdEFNaWC81V root@desktop";
  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFgm2CmB1ULN2Z0J7EMfHczSfRXoqn5K7ZWnhjTEqd8e root@work";
in
{
  "secrets/syncthing-password.age".publicKeys = [ alex_desktop alex_laptop desktop laptop ];
  "secrets/syncthing-user.age".publicKeys = [ alex_desktop alex_laptop desktop laptop ];
  "secrets/obsidian-password.age".publicKeys = [ alex_desktop alex_laptop desktop laptop ];
}
