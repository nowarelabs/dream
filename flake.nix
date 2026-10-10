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
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            devshell.overlays.default
            (import ./nix/overlay.nix { src = self; })
          ];
        };
      in
      {
        packages = {
          default = pkgs.dream;
          dream = pkgs.dream;
        };

        apps = let
          dream = flake-utils.lib.mkApp { drv = pkgs.dream; };
        in {
          default = dream;
          dream = dream;
        };

        devShells.default = pkgs.devshell.mkShell {
          devshell.name = "dream.dev";

          packages = [
            pkgs.nodejs_24
            pkgs.pnpm
            pkgs.typescript
            pkgs.typescript-language-server
            pkgs.zellij
          ];

          commands = [
            {
              name = "dream";
              help = "Start the Dream server (default port 8000, or pass a port)";
              command = "./bin/dream \"$@\"";
            }
            {
              name = "dream-dev";
              help = "Start the Dream server in watch (dev) mode";
              command = "./bin/dream-dev \"$@\"";
            }
            {
              name = "install";
              help = "Install Node dependencies with pnpm";
              command = "pnpm install --dir \"$PRJ_ROOT\"";
            }
            {
              name = "devspace";
              help = "Open the Zellij dev workspace";
              command = "zellij -l \"$PRJ_ROOT/layout.kdl\"";
            }
          ];

          env = [
            {
              name = "PATH";
              eval = "$PRJ_ROOT/bin:$PRJ_ROOT/node_modules/.bin:$PATH";
            }
          ];

          devshell.startup.setup-dream.text = ''
            chmod +x ./bin/* 2>/dev/null || true

            if [ -f package.json ] && [ ! -d node_modules ]; then
              echo "==> node_modules missing, run: pnpm install"
            fi

            echo ""
            echo "------------------------------------------------------------"
            echo " Dream Environment Ready (Node $(node --version) / TypeScript $(tsc --version | cut -d' ' -f2))"
            echo " Install:     pnpm install"
            echo " Run Server:  dream [port] (default: 8000)"
            echo " Run Dev:     dream-dev [port] (default: 8000, watch mode)"
            echo " Workspace:   devspace"
            echo "------------------------------------------------------------"
          '';
        };
      }
    );
}
