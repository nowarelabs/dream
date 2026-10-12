{ src }:
final: prev:
let
  inherit (prev) lib;

  kotlinGrpcSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/kotlin-grpc");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/kotlin-grpc");
  };

  kotlin-grpc = prev.stdenv.mkDerivation {
    pname = "kotlin-grpc";
    version = "0.1.0";

    src = kotlinGrpcSrc;

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
      mkdir -p $out/libexec/kotlin-grpc $out/bin
      cp -r . $out/libexec/kotlin-grpc/
      chmod -R u+w $out/libexec/kotlin-grpc
      chmod +x $out/libexec/kotlin-grpc/bin/* 2>/dev/null || true
      makeWrapper $out/libexec/kotlin-grpc/bin/kotlin-grpc $out/bin/kotlin-grpc \
        --prefix PATH : ${lib.makeBinPath [ prev.jdk ]} \
        --set PORT "50061"
      runHook postInstall
    '';

    meta = {
      description = "Kotlin gRPC service (grpc-java)";
      mainProgram = "kotlin-grpc";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit kotlin-grpc;
}