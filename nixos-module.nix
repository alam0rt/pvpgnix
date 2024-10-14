{ pkgs, config, lib, ... }:
let cfg = config.services.pvpgn; in {
    options = {
        services.pvpgn = {
            enable = lib.mkEnableOption "Enable the Battle.NET daemon";

            package = lib.mkOption {
                description = "pvpgn package to use";
                type = lib.types.package;
            };

            logFile = lib.mkOption rec {
                type = lib.types.str;
                default = "/dev/stdout";
                description = "Path to the log file for pvpgn. Use stdout to print into the journal";
            };
            openFirewall = lib.mkEnableOption "Allow PVPGN through the firewall.";

            bnetd.configFile = lib.mkOption {
                type = lib.types.str;
                default = "${cfg.package}/etc/pvpgn/bnetd.conf";
            };

            database.type = lib.mkOption rec {
                type = lib.types.str;
                default = "sqlite3";
                description = "The type of database that bnetd should connect to.";
            };

            database.sqlitePath = lib.mkOption rec {
                type = lib.types.str;
                default = "/tmp/users.db";
                description = "The type of database that bnetd should connect to.";
            };
        };
    };

    config = lib.mkIf config.services.pvpgn.enable {
        systemd.services.bnetd = {
            after = ["network.target"];
            enable = true;
            serviceConfig = {
              ExecStart = "${cfg.package}/sbin/bnetd -f -c ${config.services.pvpgn.bnetd.configFile}";
             # User = "pvpgn";
             # Group = "pvpgn";
            };
        };
        users.users.pvpgn =
          {
            isSystemUser = true;
            group = "pvpgn";
            description = "PVPGN user";
          };
        users.groups.pvpgn = {};

        # firewall
        networking.firewall = lib.mkIf config.services.pvpgn.openFirewall {
          allowedUDPPorts = [ 6112 ];
          allowedTCPPorts = [
            6112
          ];
        }; 
    };
}
