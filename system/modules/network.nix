###########################################################
# This file configures your online privacy, with:
# - dnscrypt-proxy2
# - networkd
#
# TEST: 
# - To test Systemd
#   networkctl
#   systemctl --type=service
#
# - To see the logs from DNSCrypt with:
#   sudo cat /var/log/dnscrypt-proxy/dnscrypt-proxy.log
#
# - To test if it works as expected:
#   dig +short txt qnamemintest.internet.nl
#   https://www.cloudflare.com/ssl/encrypted-sni/
#   https://www.youtube.com/watch?v=2oe0_v5M8cE
#
# - To simulate a pi-hole
#   https://github.com/NixOS/nixpkgs/issues/61617
#
# NOTES:
# - ESNI support is only from the browser:
#   https://github.com/DNSCrypt/dnscrypt-proxy/issues/941
#
# DOCS:
# - https://nixos.wiki/wiki/Encrypted_DNS
# - https://wiki.archlinux.org/title/Systemd-networkd
#
###########################################################

{ pkgs, ... }:

{
  # NOTE:
  # Networkd configuration example can be found at `notes.md`

  #programs.nm-applet.enable = true;

  networking = {
    networkmanager = {
      enable = true;
      ethernet.macAddress = "random";
      wifi.scanRandMacAddress = true;
    };
    wireless.userControlled.enable = false; # TODO: true for notebook
    # explicity disable dhcpcd 
    useDHCP = false;
    dhcpcd.enable = false;
    ################################################
    # defaults for DNSCrypt (both DHCP and Networkd)
    nameservers = [ "127.0.0.1" "::1" ];
    # If using dhcpcd:
    dhcpcd.extraConfig = "nohook resolv.conf";
    # If using NetworkManager:
    networkmanager.dns = "none";
    ################################################
  };

  users.extraGroups.networkmanager.members = [ "nali" "alpha" ];

  services = {
    resolved.enable = false;

    dnscrypt-proxy2 = {
      enable = true;
      settings = {
        log_file = "/var/log/dnscrypt-proxy/dnscrypt-proxy.log";
        log_file_latest = true;

        ipv6_servers = true;
        dnscrypt_servers = true;
        doh_servers = true;
        require_dnssec = true;

        # - To a faster startup when configuring this file
        # - You can choose a specific set of servers from https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v3/public-resolvers.md
        # server_names = [ "nextdns" "nextdns-ipv6" "cloudflare" "cloudflare-ipv6" ];

        ###############
        # ODoH Config #
        ###############
        # (WIP)
        #
        # CAUTION: 
        # - ODoH relays cannot be used with DNSCrypt servers, 
        # - DNSCrypt relays cannot be used to connect to ODoH servers.
        # - ODoH relays can only connect to servers supporting the ODoH protocol, not regular DoH servers.
        # In other words, only combine ODoH relays with ODoH servers.
        #
        # odoh_servers = true;
        #
        # sources.odoh-servers =
        #   {
        #     urls = [
        #       "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/odoh-servers.md"
        #       "https://download.dnscrypt.info/resolvers-list/v3/odoh-servers.md"
        #       "https://ipv6.download.dnscrypt.info/resolvers-list/v3/odoh-servers.md"
        #     ];
        #     cache_file = "odoh-servers.md";
        #     minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        #     refresh_delay = 24;
        #   };
        # sources.odoh-relays = {
        #   urls = [
        #     "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/odoh-relays.md"
        #     "https://download.dnscrypt.info/resolvers-list/v3/odoh-relays.md"
        #     "https://ipv6.download.dnscrypt.info/resolvers-list/v3/odoh-relays.md"
        #   ];
        #   cache_file = "odoh-relays.md";
        #   minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        #   refresh_delay = 24;
        # };
      };
    };
  };
}
