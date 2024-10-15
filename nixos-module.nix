{ pkgs, config, lib, ... }:
let
    name = "pvpgn";
    cfg = config.services.pvpgn;
    generators = lib.generators;

      mkValueStringPVPGN = {}: v:
        let err = t: v: abort
            ("generators.mkValueStringDefault: " +
            "${t} not supported: ${toPretty {} v}");
            in   if isInt      v then toString v
            # convert derivations to store paths
            else if isDerivation v then toString v
            # we default to not quoting strings
            else if isString   v then v
            # isString returns "1", which is not a good default
            else if true  ==   v then "true"
            # here it returns to "", which is even less of a good default
            else if false ==   v then "false"
            else if null  ==   v then "null"
            # if you have lists you probably want to replace this
            else if isList     v then err "lists" v
            # same as for lists, might want to replace
            else if isAttrs    v then err "attrsets" v
            # functions can’t be printed of course
            else if isFunction v then err "functions" v
            # Floats currently can't be converted to precise strings,
            # condition warning on nix version once this isn't a problem anymore
            # See https://github.com/NixOS/nix/pull/3480
            else if isFloat    v then floatToString v
            else err "this value is" (toString v);

    toConf = generators.toKeyValue {
      mkKeyValue = mkKeyValueDefault {} " = ";
      mkValueString = mkValueStringPVPGN;
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

            configDir = lib.mkOption {
                type = lib.types.str;
                default = "/etc/${name}";
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

                  # Storage section
                  storage_path = "sql:mode=sqlite3;name=${cfg.database.sqlitePath};default=0;prefix=pvpgn";

                  # File section
                  # variable
                  filedir = "${cfg.localStateDir}/files";
                  scriptdir = "${cfg.localStateDir}/lua";
                  reportdir = "${cfg.localStateDir}/reports";
                  chanlogdir = "${cfg.localStateDir}/chanlogs";
                  userlogdir = "${cfg.localStateDir}/userlogs";
                  i18ndir = "${cfg.localStateDir}/i18n";
                  logfile = cfg.bnetd.logFile;
                  maildir = "${cfg.localStateDir}/bnmail";
                  ladderdir = "${cfg.localStateDir}/ladders";
                  statusdir = "${cfg.localStateDir}/status";
                  #pidfile = "${cfg.localStateDir}/bnetd.pid";

                  # static
                  issuefile = "${cfg.configDir}/bnissue.txt";
                  channelfile = "${cfg.configDir}/channel.conf";
                  adfile = "${cfg.configDir}/ad.json";
                  topicfile = "${cfg.configDir}/topics.conf";
                  ipbanfile = "${cfg.configDir}/bnban.conf";
                  mpqfile = "${cfg.configDir}/autoupdate.conf";
                  realmfile = "${cfg.configDir}/realm.conf";
                  versioncheck_file = "${cfg.configDir}/versioncheck.json";
                  mapsfile = "${cfg.configDir}/bnmaps.conf";
                  xplevelfile = "${cfg.configDir}/bnxplevel.conf";
                  xpcalcfile = "${cfg.configDir}/bnxpcalc.conf";
                  topicfile = "${cfg.configDir}/topics.conf";
                  command_groups_file = "${cfg.configDir}/command_groups.conf";
                  tournament_file = "${cfg.configDir}/tournament.conf";
                  aliasfile = "${cfg.configDir}/bnalias.conf";
                  anongame_infos_file = "${cfg.configDir}/anongame_infos.conf";
                  DBlayoutfile = "${cfg.configDir}/sql_DB_layout.conf";
                  supportfile = "${cfg.configDir}/supportfile.conf";
                  transfile = "${cfg.configDir}/address_translation.conf";
                  customicons_file = "${cfg.configDir}/icons.conf";

                  # Localised files realm server settings
                  localizefile = "common.xml";
                  motdfile    = "bnmotd.txt";
                  motdw3file  = "w3motd.txt";
                  newsfile    = "news.txt";
                  helpfile    = "bnhelp.conf";
                  tosfile     = "termsofservice.txt";
                  localize_by_country = true;

                  # the rest
                  loglevels = "fatal,error,warn,info,debug,trace";
                  d2cs_version = 0;
                  allow_d2cs_setname = true;
                  iconfile = "icons.bni";
                  war3_iconfile = "icons-WAR3.bni";
                  star_iconfile = "icons_STAR.bni";
                  allowed_clients = "all";
                  allow_bad_version = true;
                  allow_unknown_version = true;
                  usersync  = 300;
                  userflush = 3600;
                  userstep = 100;
                  userflush_connected = true;
                  latency = 600;
                  nullmsg = 120;
                  shutdown_delay = 300;
                  shutdown_decr = 60;
                  new_accounts = true;
                  max_accounts = 0;
                  kick_old_login = true;
                  ask_new_channel = true;
                  report_all_games = true;
                  report_diablo_games = false;
                  hide_pass_games = true;
                  hide_started_games = true;
                  hide_temp_channels = true;
                  disc_is_loss = false;
                  ladder_games = "none";
                  ladder_prefix = "";
                  enable_conn_all = true;
                  hide_addr = false;
                  chanlog = false;
                  quota = yes;
                  quota_lines = 5;
                  quota_time = 5;
                  quota_wrapline = 40;
                  quota_maxline = 200;
                  quota_dobae = 10;
                  mail_support = true;
                  mail_quota = 5;
                  log_notice = "*** Please note this channel is logged! ***";
                  passfail_count = 0;
                  passfail_bantime = 300;
                  maxusers_per_channel = 0;
                  savebyname = true;
                  sync_on_logoff = false;
                  hashtable_size = 61;
                  account_allowed_symbols = "-_[]";
                  account_force_username = false;
                  max_friends = 20;
                  track = 0;
                  trackaddrs = "track.pvpgn.org,bntrack.darkwings.org,bnet.mivabe.nl,track.eurobattle.net";
                  location = "unknown";
                  description = "unknown";
                  url = "https://github.com/pvpgn/pvpgn-server";
                  contact_name = "a PvPGN user";
                  contact_email = "unknown";
                  max_connections = 1000;
                  packet_limit = 1000;
                  max_concurrent_logins = 0;
                  use_keepalive = false;
                  max_conns_per_IP = 0;
                  servaddrs = ":";
                  w3routeaddr = "0.0.0.0:6200";
                  initkill_timer = 120;
                  woltimezone = "-8";
                  wollongitude = "36.1083";
                  wollatitude = "-115.0582";
                  wol_autoupdate_serverhost = "westwood-patch.ea.com";
                  wol_autoupdate_username = "update";
                  wol_autoupdate_password = "world96";
                  war3_ladder_update_secs = 300;
                  XML_output_ladder = false;
                  output_update_secs = 60;
                  XML_status_output = false;
                  clan_newer_time = 0;
                  clan_max_members = 50;
                  clan_channel_default_private = 0;
                  clan_min_invites = 2;
                  log_commands = true;
                  log_command_groups = 2345678;
                  log_command_list = "";
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
