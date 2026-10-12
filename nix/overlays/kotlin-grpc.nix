{ src }:
final: prev:
let
  inherit (prev) lib;

  kotlinGrpcSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/kotlin-grpc");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/kotlin-grpc");
  };

  kotlin-grpc = prev.stdenv.mkDerivation (finalAttrs: {
    pname = "kotlin-grpc";
    version = "0.1.0";

    src = kotlinGrpcSrc;

    nativeBuildInputs = [ prev.jdk prev.gradle prev.makeWrapper ];

    mitmCache = prev.gradle.fetchDeps {
      pkg = finalAttrs.finalPackage;
      data = ./kotlin-grpc-deps.json;
    };

    __darwinAllowLocalNetworking = true;

    gradleBuildTask = "installDist";
    doCheck = false;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec $out/bin
      cp -r build/install/${finalAttrs.pname} $out/libexec/
      chmod -R u+w $out/libexec
      chmod +x $out/libexec/${finalAttrs.pname}/bin/* 2>/dev/null || true
      makeWrapper $out/libexec/${finalAttrs.pname}/bin/${finalAttrs.pname} $out/bin/${finalAttrs.pname} \
        --prefix PATH : ${lib.makeBinPath [ prev.jdk ]} \
        --set PORT "50061"
      runHook postInstall
    '';

    meta = {
      description = "Kotlin gRPC service (grpc-java)";
      mainProgram = "kotlin-grpc";
      platforms = lib.platforms.unix;
    };
  });
in
{
  inherit kotlin-grpc;
}