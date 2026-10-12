{ src }:
final: prev:
let
  inherit (prev) lib;

  kotlinKtorSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/kotlin-ktor");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/kotlin-ktor");
  };

  kotlin-ktor = prev.stdenv.mkDerivation {
    pname = "kotlin-ktor";
    version = "0.1.0";

    src = kotlinKtorSrc;

    nativeBuildInputs = [ prev.jdk prev.gradle prev.makeWrapper ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      export HOME=$(mktemp -d)
      export GRADLE_USER_HOME=$HOME/.gradle
      gradle --no-daemon --console=plain installDist
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/kotlin-ktor $out/bin
      cp -r . $out/libexec/kotlin-ktor/
      chmod -R u+w $out/libexec/kotlin-ktor
      chmod +x $out/libexec/kotlin-ktor/bin/* 2>/dev/null || true
      makeWrapper $out/libexec/kotlin-ktor/bin/kotlin-ktor $out/bin/kotlin-ktor \
        --prefix PATH : ${lib.makeBinPath [ prev.jdk ]} \
        --set PORT "3027"
      runHook postInstall
    '';

    meta = {
      description = "Kotlin Ktor HTTP service";
      mainProgram = "kotlin-ktor";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit kotlin-ktor;
}