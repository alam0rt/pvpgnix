{ pkgs, config, lib, ... }:
let
    name = "pvpgn";
    cfg = config.services.pvpgn;
    generators = lib.generators;

    toConf = generators.toKeyValue {
      mkKeyValue = generators.mkKeyValueDefault {} " = ";
    };
in {
    options = {
        services.pvpgn = {
            enable = lib.mkEnableOption "Enable the Battle.NET daemon";

            package = lib.mkOption {
                type = lib.types.package;
                description = "pvpgn package to use";
            };

            user = lib.mkOption {
                type = lib.types.str;
                default = "pvpgn";
                description = "user to run as";
            };

            group = lib.mkOption {
                type = lib.types.str;
                default = "pvpgn";
                description = "group to run as";
            };

            localStateDir = lib.mkOption {
                type = lib.types.str;
                default = "/var/run/${name}";
            };

            openFirewall = lib.mkEnableOption "Allow PVPGN through the firewall.";

            bnetd = {
              logFile = lib.mkOption rec {
                type = lib.types.str;
                default = "/dev/stdout";
                description = "Path to the log file for pvpgn. Use stdout to print into the journal";
              };
            };

            database.type = lib.mkOption rec {
                type = lib.types.str;
                default = "sqlite3";
                description = "The type of database that bnetd should connect to.";
            };

            database.sqlitePath = lib.mkOption rec {
                type = lib.types.str;
                default = "/var/run/${name}/users.db";
                description = "The type of database that bnetd should connect to.";
            };
        };
    };

    config = lib.mkIf config.services.pvpgn.enable {

        environment.etc = {
            bnetd = {
                #target = config.services.pvpgn.bnetd.configFile;
                target = "pvpgn/bnetd.conf";
                text = toConf {
                  storage_path = "foo";
                  logfile = cfg.bnetd.logFile;
                };
            };
        };

        systemd.services.bnetd = {
            after = ["network.target"];
            enable = true;
            serviceConfig = {
              ExecStart = "${cfg.package}/sbin/bnetd -f -c /etc/pvpgn/bnetd.conf";
              User = config.services.pvpgn.user;
              Group = config.services.pvpgn.group;
            };
        };
        users.users.${config.services.pvpgn.user} =
          {
            isSystemUser = true;
            group = config.services.pvpgn.group;
            description = "PVPGN user";
          };
        users.groups.${config.services.pvpgn.group} = {};

        # firewall
        networking.firewall = lib.mkIf config.services.pvpgn.openFirewall {
          allowedUDPPorts = [ 6112 6200 ];
          allowedTCPPorts = [
            6112
            6200 # confirm
          ];
        }; 
    };
}
