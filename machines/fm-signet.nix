{ config, pkgs, lib, ... }:
let
  nix-bitcoin = import ./templates/nix-bitcoin.nix;
  fedimint-override = pkgs.callPackage
    ({ stdenv, lib, rustPlatform, fetchurl, pkgs, fetchFromGitHub, openssl, pkg-config, perl, clang, jq }:
      rustPlatform.buildRustPackage rec {
        pname = "fedimint";
        version = "master";
        nativeBuildInputs = [ pkg-config perl openssl clang jq pkgs.mold ];
        doCheck = false;
        OPENSSL_DIR = "${pkgs.openssl.dev}";
        OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";  
        LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
        # TODO: compile master
        src = builtins.fetchGit {
          url = "https://github.com/fedimint/fedimint";
          ref = "hcpp";
          rev = "10d408e20e99b33e9cca102bf104324cee893134";
        };
        cargoSha256 = "sha256-rFkzIvW11DmDEn3QpcAUS7owqU8iTnjX0uTBGUlvtyc=";
        meta = with lib; {
          description = "Federated Mint Prototype";
          homepage = "https://github.com/fedimint/fedimint";
          license = licenses.mit;
          maintainers = with maintainers; [ wiredhikari ];
        };
      }) {};
  ip = "64.225.59.252";
in
{
  deployment = {
    targetHost = ip;
    tags = [ "bitcoin" "lightning" "signet" "fedimint" ];
  };

  imports = [
    ./templates/digital-ocean.nix
    <nixpkgs/nixos/modules/virtualisation/digital-ocean-image.nix>
    "${nix-bitcoin}/modules/modules.nix"
  ];
 
  networking = {
    hostName = "fm-signet";
    firewall.allowedTCPPorts = [ 80 443 5000 9735 ];
    interfaces.ens3 = {
      useDHCP = true;
      ipv4.addresses = [{
        address = ip;
        prefixLength = 24;
      }];
    };
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
  };

  security = {
    acme =  {
      defaults.email = "mail@justinmoon.com";
      acceptTerms = true;
    };
  };

  nix-bitcoin.operator = {
    enable = true;
    name = "justin";
  };

  nix-bitcoin = {
    generateSecrets = true;
    onionServices = {
      bitcoind.enable = true;
    };
    nodeinfo.enable = true;
  };

  services = {
    bitcoind = {
      enable = true;
      signet = true;
      disablewallet = true;
      dbCache = 2000;
    };

    fedimint = {
      enable = true;
      package = fedimint-override;
    };

    clightning = {
      enable = true;
      address = "0.0.0.0";
      plugins = {
        summary.enable = true;
        fedimint-gw = {
          enable = true;
          package = fedimint-override;
        };
      };
      extraConfig = ''
        announce-addr=${ip}:9735
        alias=fm-signet.justinmoon.com
        large-channels
        experimental-offers
        fee-base=0
        fee-per-satoshi=100
      '';
    };

    rtl = {
      enable = true;
      nodes.clightning.enable = true;
    };

    nginx = {
      enable = true;
      recommendedProxySettings = true;
      proxyTimeout = "1d";
      virtualHosts."fm-signet-gateway.justinmoon.com" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8080/";
          proxyWebsockets = true;
          extraConfig = "proxy_pass_header Authorization;";
        };
      };
      virtualHosts."fm-signet.justinmoon.com" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://${ip}:5000";
          proxyWebsockets = true;
          extraConfig = "proxy_pass_header Authorization;";
        };
        locations."/rtl/" = {
          proxyPass = "http://127.0.0.1:3000";
          proxyWebsockets = true;
          extraConfig = "proxy_pass_header Authorization;";
        };
      };
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "21.11"; # Did you read the comment?

  # The nix-bitcoin release version that your config is compatible with.
  # When upgrading to a backwards-incompatible release, nix-bitcoin will display an
  # an error and provide hints for migrating your config to the new release.
  nix-bitcoin.configVersion = "0.0.70";

  system.extraDependencies = [ nix-bitcoin ];
}

