{ src }:
final: prev:
let
  inherit (prev) lib;
  lua = prev.lua5_4.withPackages (ps: [ ps.luasocket ]);

  luaAppSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/lua-app");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/lua-app");
  };

  lua-app = prev.stdenv.mkDerivation {
    pname = "lua-app";
    version = "0.1.0";

    src = luaAppSrc;

    nativeBuildInputs = [ lua prev.makeWrapper ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/lua-app $out/bin
      cp -r . $out/libexec/lua-app/
      chmod -R u+w $out/libexec/lua-app
      chmod +x $out/libexec/lua-app/bin/* 2>/dev/null || true
      makeWrapper $out/libexec/lua-app/bin/lua-app $out/bin/lua-app \
        --prefix PATH : ${lib.makeBinPath [ lua ]} \
        --set PORT "4032"
      runHook postInstall
    '';

    meta = {
      description = "Lua socket HTTP service";
      mainProgram = "lua-app";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit lua-app;
}
