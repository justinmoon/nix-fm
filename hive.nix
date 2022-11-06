{
  meta = {
    nixpkgs = <nixpkgs>;
  };

  defaults = { pkgs, ... }: {
    deployment = {
      targetUser = "root";
    };

    # This module will be imported by all hosts
    environment.systemPackages = with pkgs; [
      vim wget curl
    ];

    users = {
      mutableUsers = false;
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

    nix.trustedUsers = [ "root" "@wheel" ];

    security.sudo.wheelNeedsPassword = false;

    services.openssh.enable = true;
  };

  fm-signet = import ./machines/fm-signet.nix;
}
