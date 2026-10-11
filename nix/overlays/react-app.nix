{ src }:
final: prev:
let
  inherit (prev) lib;
  nodejs = prev.nodejs_24;

  reactAppSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/react-app");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/react-app");
  };

  react-app = prev.stdenv.mkDerivation {
    pname = "react-app";
    version = "0.1.0";

    src = reactAppSrc;

    nativeBuildInputs = [ nodejs prev.pnpm prev.makeWrapper ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      export HOME=$(mktemp -d)
      pnpm install --frozen-lockfile || pnpm install
      pnpm build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/react-app $out/bin
      cp -r . $out/libexec/react-app/
      chmod -R u+w $out/libexec/react-app
      chmod +x $out/libexec/react-app/bin/* 2>/dev/null || true
      makeWrapper $out/libexec/react-app/bin/react-app $out/bin/react-app \
        --prefix PATH : ${lib.makeBinPath [ nodejs ]} \
        --set PORT "3002"
      runHook postInstall
    '';

    meta = {
      description = "React SPA service";
      mainProgram = "react-app";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit react-app;
}
