{
  description = "Dream";

  inputs.devshell.url = "github:numtide/devshell";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, flake-utils, devshell, nixpkgs, ... }:
    flake-utils.lib.eachSystem [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ] (system:
      let
        serviceNames = [
          "dream"
          "node-app"
          "next-app"
          "react-app"
          "ruby-app"
          "rails-app"
          "go-app"
          "elixir-app"
          "rust-app"
          "rust-actix"
          "rust-grpc"
          "go-gin"
          "go-grpc"
          "ts-app"
          "ts-express"
          "ts-grpc"
          "ruby-grpc"
          "c-app"
          "c-microhttpd"
          "c-grpc"
          "cpp-app"
          "cpp-crow"
          "cpp-grpc"
          "java-app"
          "java-spring"
          "java-grpc"
          "csharp-app"
          "csharp-aspnet"
          "csharp-grpc"
          "scala-app"
          "scala-http4s"
          "scala-grpc"
          "php-app"
          "php-slim"
          "php-grpc"
          "zig-app"
          "kotlin-app"
          "kotlin-ktor"
          "kotlin-grpc"
          "python-app"
          "python-flask"
          "python-grpc"
          "r-app"
          "r-plumber"
          "clojure-app"
          "clojure-compojure"
          "clojure-grpc"
          "lisp-app"
          "lisp-hunchentoot"
          "lua-app"
          "lua-lapis"
          "haskell-app"
          "haskell-scotty"
        ];

        overlays = [
          devshell.overlays.default
        ] ++ map (name: import (./nix/overlays + "/${name}.nix") { src = self; }) serviceNames ++ [
          (import ./nix/overlays/mesh.nix { src = self; })
        ];

        pkgs = import nixpkgs {
          inherit system overlays;
        };

        lib = pkgs.lib;

        mkApp = drv: flake-utils.lib.mkApp { inherit drv; };

        servicePackages = builtins.listToAttrs (map (name: {
          name = name;
          value = pkgs.${name};
        }) serviceNames);

        serviceApps = builtins.listToAttrs (map (name: {
          name = name;
          value = mkApp pkgs.${name};
        }) serviceNames);

        meshApp = flake-utils.lib.mkApp {
          drv = pkgs.mesh;
          exePath = "/bin/mesh";
        };
      in
      {
        packages = servicePackages // {
          default = pkgs.mesh;
          mesh = pkgs.mesh;
          update-deps = pkgs.writeShellScriptBin "update-deps" ''
            export PATH="${pkgs.nix}/bin:/usr/bin:/bin:/usr/sbin:/sbin"
            exec bash ${./nix/update-deps.sh} "$@"
          '';
        };

        apps = serviceApps // {
          default = meshApp;
          mesh = meshApp;
          update-deps = flake-utils.lib.mkApp {
            drv = self.packages.${system}.update-deps;
            exePath = "/bin/update-deps";
          };
        };

        devShells.default = pkgs.devshell.mkShell {
          devshell.name = "dream.dev";

          packages = [
            pkgs.nodejs_24
            pkgs.pnpm
            pkgs.typescript
            pkgs.typescript-language-server
            pkgs.ruby_3_3
            pkgs.go
            pkgs.beamPackages.elixir
            pkgs.rustc
            pkgs.cargo
            pkgs.rustfmt
            pkgs.protobuf
            pkgs.foreman
            pkgs.httpyac
            pkgs.zellij
            pkgs.stdenv.cc
            pkgs.gnumake
            pkgs.pkg-config
            pkgs.libmicrohttpd
            pkgs.crow
            pkgs.grpc
            pkgs.openjdk
            pkgs.maven
            pkgs.gradle
            pkgs.sbt
            pkgs.scala
            pkgs.kotlin
            pkgs.dotnet-sdk_8
            pkgs.php83
            pkgs.php83.packages.composer
            pkgs.R
            pkgs.lua5_4
            pkgs.luarocks
            pkgs.openresty
            pkgs.zig_0_14
            pkgs.clojure
            pkgs.leiningen
            pkgs.sbcl
            pkgs.ghc
            pkgs.cabal-install
          ];

          commands = [
            {
              name = "mesh";
              category = "monorepo";
              help = "Run every service via foreman (dev)";
              command = "$PRJ_ROOT/bin/orchestrator/mesh \"$@\"";
            }
            {
              name = "install";
              category = "monorepo";
              help = "Install Node dependencies for every service with a package.json";
              command = ''
                for dir in "$PRJ_ROOT"/services/*/; do
                  if [ -f "$dir/package.json" ]; then
                    echo "==> pnpm install in $dir"
                    (cd "$dir" && pnpm install)
                  fi
                done
              '';
            }
            {
              name = "update-deps";
              category = "monorepo";
              help = "Regenerate dependency pins/FOD hashes for a service (or --all)";
              command = "bash $PRJ_ROOT/nix/update-deps.sh \"$@\"";
            }
            {
              name = "devspace";
              category = "monorepo";
              help = "Open the Zellij dev workspace";
              command = "zellij -l \"$PRJ_ROOT/layout.kdl\"";
            }
            {
              name = "apitest";
              category = "monorepo";
              help = "Run every service's api.http via httpyac (needs services running)";
              command = ''
                rc=0
                for dir in "$PRJ_ROOT"/services/*/; do
                  name="$(basename "$dir")"
                  if [ -f "$dir/api.http" ]; then
                    echo "==> $name"
                    err="$(mktemp)"
                    if ! httpyac "$dir/api.http" --all "$@" 2>"$err"; then
                      rc=1
                      cat "$err" >&2
                    fi
                    rm -f "$err"
                  fi
                done
                test "$rc" -eq 0
              '';
            }
          ] ++ map (name: {
            name = name;
            category = "services";
            help = "Run the ${name} service";
            command = "$PRJ_ROOT/services/${name}/bin/${name} \"$@\"";
          }) serviceNames;

          env = [
            {
              name = "PATH";
              eval =
                lib.concatMapStringsSep ":" (name: "$PRJ_ROOT/services/${name}/bin") serviceNames
                + ":$PRJ_ROOT/bin/orchestrator:$PRJ_ROOT/node_modules/.bin:$PATH";
            }
          ];

          devshell.startup.setup-dream.text = ''
            chmod +x ./services/*/bin/* ./bin/orchestrator/* 2>/dev/null || true

            echo ""
            echo "------------------------------------------------------------"
            echo " Dream Monorepo Ready"
            echo " Start all:   mesh"
            echo " Start one:   <service>   (dream, node-app, go-app, ...)"
            echo " Install:     install"
            echo " Workspace:   devspace"
            echo "------------------------------------------------------------"
          '';
        };
      }
    );
}
