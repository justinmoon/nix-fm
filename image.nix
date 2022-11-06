{ pkgs ? import <nixpkgs> { } }:
let config = {
  imports = [ <nixpkgs/nixos/modules/virtualisation/digital-ocean-image.nix> ];

  users = {
    mutableUsers = false;
    users.justinmoon = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII9H+Ls/IS8yOTvUHS6e5h/EXnn5V3mg23TlqcSExiUk mail@justinmoon.com" # TODO: create separate account
      ];
      # FIXME: this password is just "password"
      hashedPassword = "$6$jRGmTJAOBciB326F$ciYQ02rULmWbZHpdSxhFxWvAuYAQRGf2Y4AFGCrOmbrXpzAE3AUnnQHvb6aCi5Ci1qFh2FqOGN/2AiNY1PHvO.";
    };
    users.justin = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII9H+Ls/IS8yOTvUHS6e5h/EXnn5V3mg23TlqcSExiUk mail@justinmoon.com" # macos
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIcHr0EbgAwPMd0I9vZgMIxJn7W2YXWGECjDseMoWGwT mail@justinmoon.com" # nixos

      ];
      # FIXME: this password is just "password"
      hashedPassword = "$6$jRGmTJAOBciB326F$ciYQ02rULmWbZHpdSxhFxWvAuYAQRGf2Y4AFGCrOmbrXpzAE3AUnnQHvb6aCi5Ci1qFh2FqOGN/2AiNY1PHvO.";
    };
  };

};
in
(pkgs.nixos config).digitalOceanImage
