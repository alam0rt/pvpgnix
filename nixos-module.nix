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
            serviceConfig.ExecStart = "${pkgs.pvpgn}/sbin/bnetd -f";
        };
    }; 
}
