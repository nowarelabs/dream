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
          "rust-grpc"
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
        };

        apps = serviceApps // {
          default = meshApp;
          mesh = meshApp;
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
            pkgs.elixir
            pkgs.beam.interpreters.erlang
            pkgs.rustc
            pkgs.cargo
            pkgs.rustfmt
            pkgs.protobuf
            pkgs.foreman
            pkgs.zellij
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
              name = "devspace";
              category = "monorepo";
              help = "Open the Zellij dev workspace";
              command = "zellij -l \"$PRJ_ROOT/layout.kdl\"";
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
