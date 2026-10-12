{ src }:
final: prev:
let
  inherit (prev) lib;
  nodejs = prev.nodejs_24;

  tsAppSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/ts-app");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/ts-app");
  };

  ts-app = prev.stdenvNoCC.mkDerivation {
    pname = "ts-app";
    version = "0.1.0";

    src = tsAppSrc;

    nativeBuildInputs = [ prev.makeWrapper ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/ts-app $out/bin
      cp -r . $out/libexec/ts-app/
      chmod -R u+w $out/libexec/ts-app
      chmod +x $out/libexec/ts-app/bin/* 2>/dev/null || true
      makeWrapper $out/libexec/ts-app/bin/ts-app $out/bin/ts-app \
        --prefix PATH : ${lib.makeBinPath [ nodejs ]} \
        --set PORT "4003"
      runHook postInstall
    '';

    meta = {
      description = "Plain TypeScript service";
      mainProgram = "ts-app";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit ts-app;
}