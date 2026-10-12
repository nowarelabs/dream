{ src }:
final: prev:
let
  inherit (prev) lib;
  nodejs = prev.nodejs_24;

  tsExpressSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/ts-express");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/ts-express");
  };

  ts-express = prev.stdenv.mkDerivation {
    pname = "ts-express";
    version = "0.1.0";

    src = tsExpressSrc;

    nativeBuildInputs = [ nodejs prev.pnpm prev.makeWrapper ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      export HOME=$(mktemp -d)
      pnpm install --config.strict-dep-builds=false
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/ts-express $out/bin
      cp -r . $out/libexec/ts-express/
      chmod -R u+w $out/libexec/ts-express
      chmod +x $out/libexec/ts-express/bin/* 2>/dev/null || true
      makeWrapper $out/libexec/ts-express/bin/ts-express $out/bin/ts-express \
        --prefix PATH : ${lib.makeBinPath [ nodejs ]} \
        --set PORT "3003"
      runHook postInstall
    '';

    meta = {
      description = "TypeScript Express service";
      mainProgram = "ts-express";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit ts-express;
}