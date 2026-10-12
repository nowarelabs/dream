{ src }:
final: prev:
let
  inherit (prev) lib;

  cAppSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/c-app");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/c-app");
  };

  c-app = prev.stdenv.mkDerivation {
    pname = "c-app";
    version = "0.1.0";

    src = cAppSrc;

    nativeBuildInputs = [ prev.makeWrapper ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      cc -O2 -o c-app src/main.c
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp c-app $out/bin/c-app
      wrapProgram $out/bin/c-app --set PORT "4020"
      runHook postInstall
    '';

    meta = {
      description = "C raw-socket HTTP service";
      mainProgram = "c-app";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit c-app;
}
