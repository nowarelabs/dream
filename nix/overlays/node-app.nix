{ src }:
final: prev:
let
  inherit (prev) lib;
  nodejs = prev.nodejs_24;

  nodeAppSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/node-app");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/node-app");
  };

  node-app = prev.stdenvNoCC.mkDerivation {
    pname = "node-app";
    version = "0.1.0";

    src = nodeAppSrc;

    nativeBuildInputs = [ prev.makeWrapper ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/node-app $out/bin
      cp -r . $out/libexec/node-app/
      chmod -R u+w $out/libexec/node-app
      chmod +x $out/libexec/node-app/bin/* 2>/dev/null || true
      makeWrapper $out/libexec/node-app/bin/node-app $out/bin/node-app \
        --prefix PATH : ${lib.makeBinPath [ nodejs ]} \
        --set PORT "4001"
      runHook postInstall
    '';

    meta = {
      description = "Node.js service";
      mainProgram = "node-app";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit node-app;
}
