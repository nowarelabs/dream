{ src }:
final: prev:
let
  inherit (prev) lib;
  openresty = prev.openresty;
  lua = prev.luajit;
  luarocks = prev.luajitPackages.luarocks;

  luaLapisSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/lua-lapis");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/lua-lapis");
  };

  lua-lapis = prev.stdenv.mkDerivation {
    pname = "lua-lapis";
    version = "0.1.0";

    src = luaLapisSrc;

    nativeBuildInputs = [ lua luarocks prev.unzip prev.curl prev.pkg-config prev.makeWrapper ];
    buildInputs = [ prev.openssl ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      export HOME=$(mktemp -d)
      luarocks install --tree="$out/share/lua-rocks" lapis \
        CRYPTO_DIR=${prev.openssl.dev} \
        CRYPTO_INCDIR=${prev.openssl.dev}/include \
        CRYPTO_LIBDIR=${prev.openssl.out}/lib \
        OPENSSL_DIR=${prev.openssl.dev} \
        OPENSSL_INCDIR=${prev.openssl.dev}/include \
        OPENSSL_LIBDIR=${prev.openssl.out}/lib
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/lua-lapis $out/bin
      cp -r . $out/libexec/lua-lapis/
      chmod -R u+w $out/libexec/lua-lapis
      printf '%s\n' \
        '#!/bin/sh' \
        'set -eu' \
        'export PORT="''${PORT:-3032}"' \
        'export LUA_PATH="${placeholder "out"}/share/lua-rocks/share/lua/5.1/?.lua;${placeholder "out"}/share/lua-rocks/share/lua/5.1/?/init.lua;;"' \
        'export LUA_CPATH="${placeholder "out"}/share/lua-rocks/lib/lua/5.1/?.so;;"' \
        'export PATH="${lib.makeBinPath [ openresty lua luarocks ]}:${placeholder "out"}/share/lua-rocks/bin:$PATH"' \
        'RUNDIR="$(mktemp -d)"' \
        'cp "${placeholder "out"}/libexec/lua-lapis/nginx.conf" "${placeholder "out"}/libexec/lua-lapis/config.lua" "${placeholder "out"}/libexec/lua-lapis/app.lua" "$RUNDIR/"' \
        'cd "$RUNDIR"' \
        'mkdir -p temp' \
        'exec lapis server development' \
        > $out/bin/lua-lapis
      chmod +x $out/bin/lua-lapis
      runHook postInstall
    '';

    meta = {
      description = "Lua Lapis HTTP service";
      mainProgram = "lua-lapis";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit lua-lapis;
}
