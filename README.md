# Dream

A polyglot monorepo: one service per language/runtime, each with its own Nix
overlay, plus a single orchestrator that boots them all on distinct ports.

## Requirements

- macOS on Apple silicon or Linux (`aarch64-darwin`, `aarch64-linux`, `x86_64-linux`)
- [Nix](https://nixos.org/download/) with flakes enabled
- [direnv](https://direnv.net/) (optional, for automatic shell loading)

## Services

| Service      | Runtime          | Port  | Dev launcher                   |
| ------------ | ---------------- | ----- | ------------------------------ |
| `dream`      | Node / TypeScript| 8000  | `dream`                        |
| `next-app`   | Next.js          | 3000  | `next-app`                     |
| `rails-app`  | Ruby / Puma      | 3001  | `rails-app`                    |
| `react-app`  | React / Vite     | 3002  | `react-app`                    |
| `elixir-app` | Elixir           | 4000  | `elixir-app`                   |
| `node-app`   | Node.js          | 4001  | `node-app`                     |
| `ruby-app`   | Ruby / WEBrick   | 4002  | `ruby-app`                     |
| `go-app`     | Go               | 8080  | `go-app`                       |
| `rust-grpc`  | Rust             | 50051 | `rust-grpc`                    |

Each service lives in `services/<name>/` and ships its own launcher at
`services/<name>/bin/<name>`. Checked-in payloads go under `vendor/<name>/`.

## Quick start

```bash
nix develop        # enter the dev shell (all runtimes + foreman + zellij)
install            # pnpm install for every service with a package.json
monorepo-start     # boot every service at once via foreman (Procfile)
```

Inside the shell each service can also be run on its own, e.g. `dream`,
`node-app`, `go-app`. `direnv allow` can replace `nix develop` to load the shell
automatically on `cd`.

### Run without the dev shell

```bash
nix run .#monorepo-runner   # foreman boots every service
nix run .#dream             # run a single service
nix build .#dream           # build result/bin/dream
```

Bare services (`dream`, `node-app`, `go-app`, `rust-grpc`) build with no network
access. The JavaScript bundlers and Ruby/Elixir services need their lockfile
hashes filled in before `nix build` will fetch dependencies.

### Devshell commands

Run `menu` inside the shell to list every command.

| Command          | Purpose                                            |
| ---------------- | -------------------------------------------------- |
| `monorepo-start` | Boot every service with `foreman` (`Procfile`)      |
| `<service>`      | Boot one service (e.g. `dream`, `go-app`)           |
| `install`        | `pnpm install` for every service with a `package.json` |
| `devspace`       | Open the Zellij dev workspace (`layout.kdl`)         |
| `menu`           | Print the command menu                             |

## Layout

| Path                         | Purpose                                              |
| ---------------------------- | ---------------------------------------------------- |
| `flake.nix`                  | composes overlays, packages, apps, and the devshell  |
| `nix/overlays/<service>.nix` | one build recipe per service                         |
| `Procfile`                   | foreman process table (`name: name`)                 |
| `bin/orchestrator/`          | monorepo-only launcher (`monorepo-start`)            |
| `services/<name>/`           | service sources + its `bin/` launcher                |
| `vendor/<name>/`             | checked-in per-service payloads                      |
| `layout.kdl`                 | Zellij workspace layout used by `devspace`           |

## Notes

- `nix build` / `nix run` only see git-tracked files. `git add` new sources
  before building.
- Node 24 runs TypeScript directly via native type stripping, so `dream` has no
  separate build step.
- Port 5000 is reserved by macOS AirPlay, so `go-app` defaults to 8080.
