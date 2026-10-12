{ src }:
final: prev:
let
  inherit (prev) lib;

  javaGrpcSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/java-grpc");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/java-grpc");
  };

  java-grpc = prev.maven.buildMavenPackage {
    pname = "java-grpc";
    version = "0.1.0";

    src = javaGrpcSrc;

    mvnHash = "sha256-2f8Pa0spSWebMoUm9JSUla3h0NZXAH+9YYlElaJiXxk=";
    doCheck = false;

    nativeBuildInputs = [ prev.makeWrapper ];

    installPhase = ''
      runHook preInstall
      rm -rf .m2
      mkdir -p $out/libexec/java-grpc $out/bin
      cp -r . $out/libexec/java-grpc/
      chmod -R u+w $out/libexec/java-grpc
      chmod +x $out/libexec/java-grpc/bin/* 2>/dev/null || true
      makeWrapper $out/libexec/java-grpc/bin/java-grpc $out/bin/java-grpc \
        --prefix PATH : ${lib.makeBinPath [ prev.jdk ]} \
        --set PORT "50057"
      runHook postInstall
    '';

    meta = {
      description = "Java gRPC service (grpc-java)";
      mainProgram = "java-grpc";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit java-grpc;
}
