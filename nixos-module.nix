{ pkgs, config, lib, ... }:
let
    name = "pvpgn";
    cfg = config.services.pvpgn;
    generators = lib.generators;
    pvpgn = cfg.package;

    toConf = generators.toKeyValue {
      mkKeyValue = generators.mkKeyValueDefault {
        mkValueString = v:
		    if lib.isInt      v then toString v
		    # convert derivations to store paths
		    else if lib.isDerivation v then toString v
		    # we default to not quoting strings
                    else if lib.isString v && lib.hasInfix " " v then "\"${v}\""
                    # empty string should return ""
                    else if lib.isString v && "" == v then "\"\""
		    else if lib.isString   v then v
		    # isString returns "1", which is not a good default
		    else if true  ==   v then "true"
		    # here it returns to "", which is even less of a good default
		    else if false ==   v then "false"
		    else if null  ==   v then "null"
                    else generators.mkValueStringDefault {} v;
      } " = ";
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
              servername = lib.mkOption {
                type = lib.types.str;
                default = "PvPGN Realm";
                description = "Servername by which the server identifies itself.";
              };
              logFile = lib.mkOption {
                type = lib.types.str;
                default = "/var/log/bnetd.log";
                description = "Path to the log file for pvpgn. Use stdout to print into the journal";
              };
            };

            news = lib.mkOption {
              type = lib.types.str;
              default = builtins.readFile "${pvpgn}/etc/pvpgn/i18n/news.txt";
              description = "The news announcement displayed when a user logs in";
            };
            tos = lib.mkOption {
              type = lib.types.str;
              default = builtins.readFile "${pvpgn}/etc/pvpgn/i18n/termsofservice.txt";
              description = "Server terms of service";
            };
            motd = lib.mkOption {
              type = lib.types.str;
              default = builtins.readFile "${pvpgn}/etc/pvpgn/i18n/news.txt";
              description = "Message of the day displayed to users";
            };
            newaccount = lib.mkOption {
              type = lib.types.str;
              default = builtins.readFile "${pvpgn}/etc/pvpgn/i18n/newaccount.txt";
              description = "The message displayed when a new user is created";
            };
            wc3 = {
              chathelp = lib.mkOption {
                type = lib.types.str;
                default = builtins.readFile "${pvpgn}/etc/pvpgn/i18n/chathelp-war3.txt";
                description = "Message returned when running /help";
              };
              motd = lib.mkOption {
                type = lib.types.str;
                default = builtins.readFile "${pvpgn}/etc/pvpgn/i18n/w3motd.txt";
                description = "Message of the day when user log in";
              };
            };
            database.type = lib.mkOption {
                type = lib.types.str;
                default = "sqlite3";
                description = "The type of database that bnetd should connect to.";
            };
        };
    };

    config = lib.mkIf config.services.pvpgn.enable {

        environment.etc = {
            bnissue = {
              target = "pvpgn/bnissue.txt";
              source = "${pvpgn}/etc/pvpgn/bnissue.txt";
              user = cfg.user;
              group = cfg.group;
            };
            i18n_bnhelp = {
              target = "pvpgn/i18n/bnhelp.conf";
              source = "${pvpgn}/etc/pvpgn/i18n/bnhelp.conf";
              user = cfg.user;
              group = cfg.group;
            };
            motdfile = {
              target = "pvpgn/i18n/bnmotd.txt";
              text = cfg.motd;
              user = cfg.user;
              group = cfg.group;
            };
            chathelpw3file = {
              target = "pvpgn/i18n/chathelp-war3.txt";
              text = cfg.wc3.chathelp;
              user = cfg.user;
              group = cfg.group;
            };
            localizefile = {
              target = "pvpgn/i18n/common.xml";
              source = "${pvpgn}/etc/pvpgn/i18n/common.xml";
              user = cfg.user;
              group = cfg.group;
            };
            newaccountfile = {
              target = "pvpgn/i18n/newaccount.txt";
              text = cfg.newaccount;
              user = cfg.user;
              group = cfg.group;
            };
            newsfile = {
              target = "pvpgn/i18n/news.txt";
              text = cfg.news;
              user = cfg.user;
              group = cfg.group;
            };
            tosfile = {
              target = "pvpgn/i18n/termsofservice.txt";
              text = cfg.tos;
              user = cfg.user;
              group = cfg.group;
            };
            motdw3file = {
              target = "pvpgn/i18n/w3motd.txt";
              text = cfg.wc3.motd;
              user = cfg.user;
              group = cfg.group;
            };
            address_translation = {
              target = "pvpgn/address_translation.conf";
              source = "${pvpgn}/etc/pvpgn/address_translation.conf";
              user = cfg.user;
              group = cfg.group;
            };
            anongame_infos = {
              target = "pvpgn/anongame_infos.conf";
              source = "${pvpgn}/etc/pvpgn/anongame_infos.conf";
              user = cfg.user;
              group = cfg.group;
            };
            bnmaps = {
              target = "pvpgn/bnmaps.conf";
              source = "${pvpgn}/etc/pvpgn/bnmaps.conf";
              user = cfg.user;
              group = cfg.group;
            };
            d2dbs = {
              target = "pvpgn/d2dbs.conf";
              source = "${pvpgn}/etc/pvpgn/d2dbs.conf";
              user = cfg.user;
              group = cfg.group;
            };
            icons = {
              target = "pvpgn/icons.conf";
              source = "${pvpgn}/etc/pvpgn/icons.conf";
              user = cfg.user;
              group = cfg.group;
            };
            sql_DB_layout = {
              target = "pvpgn/sql_DB_layout.conf";
              source = "${pvpgn}/etc/pvpgn/sql_DB_layout.conf";
              user = cfg.user;
              group = cfg.group;
            };
            bnxplevel = {
              target = "pvpgn/bnxplevel.conf";
              source = "${pvpgn}/etc/pvpgn/bnxplevel.conf";
              user = cfg.user;
              group = cfg.group;
            };
            bnxpcalc = {
              target = "pvpgn/bnxpcalc.conf";
              source = "${pvpgn}/etc/pvpgn/bnxpcalc.conf";
              user = cfg.user;
              group = cfg.group;
            };
            d2cs = {
              target = "pvpgn/d2cs.conf";
              source = "${pvpgn}/etc/pvpgn/d2cs.conf";
              user = cfg.user;
              group = cfg.group;
            };
            bnetd_default_user = {
              target = "pvpgn/bnetd_default_user.plain";
              source = "${pvpgn}/etc/pvpgn/bnetd_default_user.plain";
              user = cfg.user;
              group = cfg.group;
            };
            realm = {
              target = "pvpgn/realm.conf";
              source = "${pvpgn}/etc/pvpgn/realm.conf";
              user = cfg.user;
              group = cfg.group;
            };
            command_groups = {
              target = "pvpgn/command_groups.conf";
              source = "${pvpgn}/etc/pvpgn/command_groups.conf";
              user = cfg.user;
              group = cfg.group;
            };
            ad = {
              target = "pvpgn/ad.json";
              source = "${pvpgn}/etc/pvpgn/ad.json";
              user = cfg.user;
              group = cfg.group;
            };
            autoupdate = {
              target = "pvpgn/autoupdate.conf";
              source = "${pvpgn}/etc/pvpgn/autoupdate.conf";
              user = cfg.user;
              group = cfg.group;
            };
            tournament = {
              target = "pvpgn/tournament.conf";
              source = "${pvpgn}/etc/pvpgn/tournament.conf";
              user = cfg.user;
              group = cfg.group;
            };
            supportfile = {
              target = "pvpgn/supportfile.conf";
              source = "${pvpgn}/etc/pvpgn/supportfile.conf";
              user = cfg.user;
              group = cfg.group;
            };
            versioncheck = {
              target = "pvpgn/versioncheck.json";
              source = "${pvpgn}/etc/pvpgn/versioncheck.json";
              user = cfg.user;
              group = cfg.group;
            };
            topics = {
              target = "pvpgn/topics.conf";
              source = "${pvpgn}/etc/pvpgn/topics.conf";
              user = cfg.user;
              group = cfg.group;
            };
            bnalias = {
              target = "pvpgn/bnalias.conf";
              source = "${pvpgn}/etc/pvpgn/bnalias.conf";
              user = cfg.user;
              group = cfg.group;
            };
            channel = {
              target = "pvpgn/channel.conf";
              source = "${pvpgn}/etc/pvpgn/channel.conf";
              user = cfg.user;
              group = cfg.group;
            };
            bnban = {
              target = "pvpgn/bnban.conf";
              source = "${pvpgn}/etc/pvpgn/bnban.conf";
              user = cfg.user;
              group = cfg.group;
            };
            bnetd = {
                target = "pvpgn/bnetd.conf";
                user = cfg.user;
                group = cfg.group;
                text = toConf {

                  # general
                  servername = cfg.bnetd.servername;
                  logfile = cfg.bnetd.logFile;

                  # Storage section
                  storage_path = "sql:mode=sqlite3;name=${cfg.localStateDir}/users.db;default=0;prefix=pvpgn";

                  # File section
                  # variable
                  filedir = "${cfg.localStateDir}/files";
                  scriptdir = "${cfg.localStateDir}/lua";
                  reportdir = "${cfg.localStateDir}/reports";
                  chanlogdir = "${cfg.localStateDir}/chanlogs";
                  userlogdir = "${cfg.localStateDir}/userlogs";
                  maildir = "${cfg.localStateDir}/bnmail";
                  ladderdir = "${cfg.localStateDir}/ladders";
                  statusdir = "${cfg.localStateDir}/status";
                  #pidfile = "${cfg.localStateDir}/bnetd.pid";
                  ipbanfile = "${cfg.localStateDir}/bnban.conf"; # normally lives in etc but is written to

                  # static
                  i18ndir = "${cfg.configDir}/i18n";
                  issuefile = "${cfg.configDir}/bnissue.txt";
                  channelfile = "${cfg.configDir}/channel.conf";
                  adfile = "${cfg.configDir}/ad.json";
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
                  localize_by_country = false; # i don't care

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
                  quota = "yes";
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
              ExecStart = "${pvpgn}/sbin/bnetd -f -c /etc/pvpgn/bnetd.conf";
              User = config.services.pvpgn.user;
              Group = config.services.pvpgn.group;
              Restart = "always";
              X-Restart-Triggers = [ 
                "${config.environment.etc."newsfile".source}" 
                "${config.environment.etc."motdfile".source}" 
                "${config.environment.etc."motdw3file".source}" 
                "${config.environment.etc."newaccountfile".source}" 
                "${config.environment.etc."tosfile".source}" 
                "${config.environment.etc."bnetd".source}" 
              ]; 
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
