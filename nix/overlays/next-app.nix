{ src }:
final: prev:
let
  inherit (prev) lib;
  nodejs = prev.nodejs_24;

  nextAppSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/next-app");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/next-app");
  };

  next-app = prev.stdenv.mkDerivation {
    pname = "next-app";
    version = "0.1.0";

    src = nextAppSrc;

    nativeBuildInputs = [ nodejs prev.pnpm prev.makeWrapper ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      export HOME=$(mktemp -d)
      pnpm install --config.strict-dep-builds=false
      pnpm build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/next-app $out/bin
      cp -r . $out/libexec/next-app/
      chmod -R u+w $out/libexec/next-app
      chmod +x $out/libexec/next-app/bin/* 2>/dev/null || true
      makeWrapper $out/libexec/next-app/bin/next-app $out/bin/next-app \
        --prefix PATH : ${lib.makeBinPath [ nodejs ]} \
        --set PORT "3000"
      runHook postInstall
    '';

    meta = {
      description = "Next.js service";
      mainProgram = "next-app";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit next-app;
}
