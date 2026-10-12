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
| `ts-express` | Node / Express   | 3003  | `ts-express`                   |
| `go-gin`     | Go / Gin         | 3004  | `go-gin`                       |
| `rust-actix` | Rust / Actix-Web | 3005  | `rust-actix`                   |
| `elixir-app` | Elixir           | 4000  | `elixir-app`                   |
| `node-app`   | Node.js          | 4001  | `node-app`                     |
| `ruby-app`   | Ruby / WEBrick   | 4002  | `ruby-app`                     |
| `ts-app`     | Node / TypeScript| 4003  | `ts-app`                       |
| `rust-app`   | Rust             | 4004  | `rust-app`                     |
| `go-app`     | Go               | 8080  | `go-app`                       |
| `rust-grpc`  | Rust             | 50051 | `rust-grpc`                    |
| `ruby-grpc`  | Ruby / gRPC      | 50052 | `ruby-grpc`                    |
| `c-app`      | C                | 4020  | `c-app`                        |
| `c-microhttpd` | C / libmicrohttpd | 3020 | `c-microhttpd`               |
| `c-grpc`     | C / gRPC         | 50055 | `c-grpc`                       |
| `cpp-app`    | C++              | 4021  | `cpp-app`                      |
| `cpp-crow`   | C++ / Crow       | 3021  | `cpp-crow`                     |
| `cpp-grpc`   | C++ / gRPC       | 50056 | `cpp-grpc`                     |
| `java-app`   | Java             | 4022  | `java-app`                     |
| `java-spring`| Java / Spring    | 3022  | `java-spring`                  |
| `java-grpc`  | Java / gRPC      | 50057 | `java-grpc`                    |
| `csharp-app` | C#               | 4023  | `csharp-app`                   |
| `csharp-aspnet` | C# / ASP.NET  | 3023  | `csharp-aspnet`                |
| `csharp-grpc`| C# / gRPC        | 50058 | `csharp-grpc`                  |
| `scala-app`  | Scala            | 4024  | `scala-app`                    |
| `scala-http4s` | Scala / http4s | 3024  | `scala-http4s`                 |
| `scala-grpc` | Scala / gRPC     | 50059 | `scala-grpc`                   |
| `php-app`    | PHP              | 4025  | `php-app`                      |
| `php-slim`   | PHP / Slim       | 3025  | `php-slim`                     |
| `php-grpc`   | PHP / gRPC       | 50060 | `php-grpc`                     |
| `kotlin-app` | Kotlin           | 4027  | `kotlin-app`                   |
| `kotlin-ktor`| Kotlin / Ktor    | 3027  | `kotlin-ktor`                  |
| `kotlin-grpc`| Kotlin / gRPC    | 50061 | `kotlin-grpc`                  |
| `python-app` | Python           | 4028  | `python-app`                   |
| `python-flask` | Python / Flask | 3028  | `python-flask`                 |
| `python-grpc`| Python / gRPC    | 50062 | `python-grpc`                  |
| `r-app`      | R                | 4029  | `r-app`                        |
| `r-plumber`  | R / plumber      | 3029  | `r-plumber`                    |
| `zig-app`    | Zig              | 4026  | `zig-app`                      |
| `clojure-app`| Clojure          | 4030  | `clojure-app`                  |
| `clojure-compojure` | Clojure / Compojure | 3030 | `clojure-compojure`       |
| `clojure-grpc` | Clojure / gRPC | 50063 | `clojure-grpc`                 |
| `lisp-app`   | Common Lisp      | 4031  | `lisp-app`                     |
| `lisp-hunchentoot` | Lisp / Hunchentoot | 3031 | `lisp-hunchentoot`        |
| `lua-app`    | Lua              | 4032  | `lua-app`                      |
| `lua-lapis`  | Lua / Lapis      | 3032  | `lua-lapis`                    |
| `haskell-app`| Haskell          | 4033  | `haskell-app`                  |
| `haskell-scotty` | Haskell / Scotty | 3033 | `haskell-scotty`             |
| `go-grpc`    | Go / gRPC        | 50053 | `go-grpc`                      |
| `ts-grpc`    | Node / gRPC      | 50054 | `ts-grpc`                      |

Each service lives in `services/<name>/` and ships its own launcher at
`services/<name>/bin/<name>`. Checked-in payloads go under `vendor/<name>/`.
Every service also has an `services/<name>/api.http` file (HTTP or gRPC) that
can be executed with [httpyac](https://httpyac.github.io/).

## API tests

Run one service (needs that service running, e.g. via `mesh`):

```bash
httpyac services/react-app/api.http --all
```

Run every service's tests at once:

```bash
mesh &          # boot all services
apitest         # runs every services/<name>/api.http via httpyac
```

gRPC files load the shared `echo.proto` via `proto < proto/echo.proto` and call
`echo.Echo/Say` on their port, asserting the status code and echoed `message`.
HTTP files assert status, `content-type`, and the expected JSON body fields,
so a non-zero exit proves the API isn't behaving as expected.

## Quick start

```bash
nix develop        # enter the dev shell (all runtimes + foreman + zellij)
install            # pnpm install for every service with a package.json
mesh               # boot every service at once via foreman (Procfile)
```

Inside the shell each service can also be run on its own, e.g. `dream`,
`node-app`, `go-app`. `direnv allow` can replace `nix develop` to load the shell
automatically on `cd`.

### Run without the dev shell

```bash
nix run .#mesh              # foreman boots every service
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
| `mesh`           | Boot every service with `foreman` (`Procfile`)      |
| `<service>`      | Boot one service (e.g. `dream`, `go-app`)           |
| `install`        | `pnpm install` for every service with a `package.json` |
| `devspace`       | Open the Zellij dev workspace (`layout.kdl`)         |
| `apitest`        | Run every `services/*/api.http` via httpyac          |
| `menu`           | Print the command menu                             |

## Layout

| Path                         | Purpose                                              |
| ---------------------------- | ---------------------------------------------------- |
| `flake.nix`                  | composes overlays, packages, apps, and the devshell  |
| `nix/overlays/<service>.nix` | one build recipe per service                         |
| `Procfile`                   | foreman process table (`name: name`)                 |
| `bin/orchestrator/`          | monorepo-only launcher (`mesh`)                      |
| `services/<name>/`           | service sources + its `bin/` launcher                |
| `vendor/<name>/`             | checked-in per-service payloads                      |
| `layout.kdl`                 | Zellij workspace layout used by `devspace`           |

## Notes

- `nix build` / `nix run` only see git-tracked files. `git add` new sources
  before building.
- Node 24 runs TypeScript directly via native type stripping, so `dream` has no
  separate build step.
- Port 5000 is reserved by macOS AirPlay, so `go-app` defaults to 8080.
