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
        version = "1.99.7.2.1";
      in {
        packages = {
          default = (with pkgs; with lib; stdenv.mkDerivation {
            pname = "pvpgn-server";
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
            withSqlite3 = true;
            withLua = true;
            configureFlags = [ # add as configurable
              "-D WITH_SQLITE3=true"
              "-D WITH_LUA=true"
            ];
            inherit version;
            src = fetchgit {
              url = "https://github.com/pvpgn/pvpgn-server";
              rev = version;
              sha256 = "sha256-6cY8Q2/fVs2swO1lvMK4vzDE4cU+JAtNhtXNrJwuS/w=";
            };
            buildPhase = ''
            '';
 #           postInstall = ''
 #             ls -al; false
 #             find share/man -type f \
 #               | xargs basename \
 #               | awk -F. '{print $(NF-1) ; print $0}' \
 #               | xargs -L 2 sh -c 'cp share/man/$1 $out/share/man/man$0'
 #           '';
            nativeBuildInputs = [cmake gcc perl lua zlib sqlite];
          });
        };

        apps.default = utils.lib.mkApp { drv = self.packages.${system}.default; };
      });
}
