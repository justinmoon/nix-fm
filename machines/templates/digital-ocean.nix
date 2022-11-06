{ name, nodes, lib, modulesPath, ... }: {
    # Like NixOps and morph, Colmena will attempt to connect to
    # the remote host using the attribute name by default. You
    # can override it like:
    deployment.targetHost = "143.198.28.182";

    # Override the default for this target host
    deployment.replaceUnknownProfiles = false;

    # You can filter hosts by tags with --on @tag-a,@tag-b.
    # In this example, you can deploy to hosts with the "web" tag using:
    #    colmena apply --on @web
    # You can use globs in tag matching as well:
    #    colmena apply --on '@infra-*'
    deployment.tags = [ "web" "infra-lax" ];

    time.timeZone = "America/Los_Angeles";

    boot.loader.grub.device = "/dev/vda";
    fileSystems."/" = {
      device = "/dev/vda1";
      fsType = "ext4";
    };
}