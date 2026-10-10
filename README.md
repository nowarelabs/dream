# Dream

Dream server, implemented in TypeScript and running on
Node.js.

The whole toolchain — Node 24, `pnpm`, and the TypeScript compiler — is
provided by Nix, so there is no global install and no version drift.

## Requirements

- macOS on Apple silicon or Linux (`aarch64-darwin`, `aarch64-linux`, `x86_64-linux`)
- [Nix](https://nixos.org/download/) with flakes enabled
- [direnv](https://direnv.net/) (optional, for automatic shell loading)

## Quick start

```bash
nix develop     # enter the dev shell
pnpm install    # install dependencies
dream           # serve on port 8000
dream 8123      # serve on a custom port
dream-dev       # dev mode: same server with --watch
```

`direnv allow` can be used in place of `nix develop` to load the shell
automatically on `cd`.

### Run without the dev shell

The server is also exposed as a Nix package (see `nix/overlay.nix`):

```bash
nix run .#dream          # run the server
nix run .#dream -- 8123  # run on a custom port
nix build .#dream        # build result/bin/dream
```

### Devshell commands

Run `menu` inside the shell to list every command.

| Command     | Purpose                                              |
| ----------- | ---------------------------------------------------- |
| `dream`     | Start the server (default port 8000, or pass a port) |
| `dream-dev` | Start the server in watch mode                       |
| `install`   | Install Node dependencies with `pnpm`                |
| `devspace`  | Open the Zellij dev workspace (`layout.kdl`)         |
| `menu`      | Print the command menu                               |

The `dream` and `dream-dev` launchers pass any extra arguments straight to
`src/main.ts`, so `dream <subcommand>` works for one-shot CLI use as well.

## Layout

| Path              | Purpose                                                        |
| ----------------- | -------------------------------------------------------------- |
| `flake.nix`       | devshell + package/app outputs (Node 24, `pnpm`, TypeScript)   |
| `nix/overlay.nix` | project overlay: builds the `dream` package                    |
| `layout.kdl`      | Zellij workspace layout used by `devspace`                     |
| `bin/dream`       | launcher: serve (default port 8000)                            |
| `bin/dream-dev`   | launcher: serve with `--watch`                                 |
| `src/main.ts`     | server entry point (run directly by Node 24)                   |
| `.envrc`          | direnv `use flake`                                             |

## Notes

- Node 24 runs TypeScript directly via native type stripping, so there is no
  separate build step.
- `dream` and `dream-dev` require `pnpm install` first when a `package.json`
  is present; the devshell startup block warns when `node_modules` is missing.
- `nix build` / `nix run` only see files tracked by git. Add `src/main.ts`
  with `git add` before building the package.
- The devshell and package are provided for `aarch64-darwin`, `aarch64-linux`,
  and `x86_64-linux`.
