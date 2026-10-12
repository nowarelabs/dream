{ src }:
final: prev:
let
  inherit (prev) lib;

  kotlinAppSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/kotlin-app");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/kotlin-app");
  };

  kotlin-app = prev.stdenv.mkDerivation {
    pname = "kotlin-app";
    version = "0.1.0";

    src = kotlinAppSrc;

    nativeBuildInputs = [ prev.jdk prev.kotlin prev.makeWrapper ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      mkdir -p classes
      kotlinc src/Main.kt -d classes
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/kotlin-app $out/bin
      cp -r . $out/libexec/kotlin-app/
      chmod -R u+w $out/libexec/kotlin-app
      chmod +x $out/libexec/kotlin-app/bin/* 2>/dev/null || true
      makeWrapper $out/libexec/kotlin-app/bin/kotlin-app $out/bin/kotlin-app \
        --prefix PATH : ${lib.makeBinPath [ prev.jdk prev.kotlin ]} \
        --set PORT "4027"
      runHook postInstall
    '';

    meta = {
      description = "Kotlin HTTP service (JDK HttpServer)";
      mainProgram = "kotlin-app";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit kotlin-app;
}