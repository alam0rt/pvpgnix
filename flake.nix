{
  description = "PVPGN";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachSystem [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        name = "pvpgn-server";
        version = "1.99.7.2.1";
      in {
        nixosModules.default = 
          { config, pkgs, lib, ... }: {
            options = {
              services.pvpgn = {
                enable = lib.mkEnableOption "pvpgn"; # better description
                logFile = lib.mkOption {
                  type = lib.types.str;
                  default = "/dev/stdout"; # 
                  description = "Path to the log file for pvpgn. Use stdout to print into the journal";
                };
                database.type = lib.mkOption {
                  type = lib.types.str;
                  default = "sqlite3";
                  description = "The type of database that bnetd should connect to.";
                };
                database.sqlitePath = lib.mkOption {
                  type = lib.types.str;
                  default = "/tmp/users.db";
                  description = "The type of database that bnetd should connect to.";
                };
              };
            };

            config = lib.mkIf config.services.pvpgn.enable {
              systemd.services.pvpgn = {
                name = "bnetd";
                after = ["network.target"];
                serviceConfig.ExecStart = "${self.packages.${pkgs.system}.default}/sbin/bnetd -f";
              };
            }; 
          };
        packages = {
          docker = pkgs.dockerTools.buildLayeredImage {
            inherit name;
            tag = version;
            contents = [self.packages.${system}.default];
            config = {
              Cmd = ["${self.packages.${system}.default}/sbin/bnetd"];
              ExposedPorts = {"6112/tcp" = {};};
            };
          };
          default = (with pkgs; with lib; with config; stdenv.mkDerivation {
            mainProgram = "bnetd";
            license = "gpl2";
            homepage = "https://github.com/pvpgn/pvpgn-server";
            description = ''
              PvPGN is a free and open source cross-platform server software
              that supports Battle.net and and Westwood Online game clients.
              
              PvPGN-PRO is a fork of the official PvPGN project, whose
              development stopped in 2011, and aims to provide continued
              maintenance and additional features for PvPGN.
            '';
            cmakeFlags = [ # add as configurable
              "-DWITH_SQLITE3=true"
              "-DWITH_LUA=false" # requires lua5.1 https://stackoverflow.com/questions/10087226/lua-5-2-lua-globalsindex-alternative
            ];
            inherit version;
            pname = name;
            src = fetchgit {
              url = "https://github.com/pvpgn/pvpgn-server";
              rev = version;
              sha256 = "sha256-6cY8Q2/fVs2swO1lvMK4vzDE4cU+JAtNhtXNrJwuS/w=";
            };
            postInstall = ''
              sed -i 's#^logfile.*#logfile = "/dev/stdout"#g' $out/etc/pvpgn/bnetd.conf
              sed -i 's#^storage_path.*#storage_path = "sql:mode=sqlite3;name=/tmp/users.db;default=0;prefix=pvpgn_"#g' $out/etc/pvpgn/bnetd.conf
              sed -i 's#^ladderdir.*#ladderdir = "/tmp/ladders"#g' $out/etc/pvpgn/bnetd.conf
              sed -i 's#^statusdir.*#statusdir = "/tmp/status"#g' $out/etc/pvpgn/bnetd.conf
            '';
            nativeBuildInputs = [cmake gcc perl lua zlib sqlite];
          });
        };

        apps.default = utils.lib.mkApp { drv = self.packages.${system}.default; };
      });
}
