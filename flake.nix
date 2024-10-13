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
          default = (with pkgs; stdenv.mkDerivation {
            pname = "pvpgn-server";
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
            nativeBuildInputs = [cmake gcc perl lua zlib sqlite];
          });
        };

        apps.default = utils.lib.mkApp { drv = self.packages.${system}.default; };
      });
}
