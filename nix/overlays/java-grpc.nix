{ src }:
final: prev:
let
  inherit (prev) lib;

  javaGrpcSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/java-grpc");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/java-grpc");
  };

  java-grpc = prev.stdenv.mkDerivation {
    pname = "java-grpc";
    version = "0.1.0";

    src = javaGrpcSrc;

    nativeBuildInputs = [ prev.jdk prev.maven prev.makeWrapper ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      export HOME=$(mktemp -d)
      cat > $HOME/maven-settings.xml <<'EOF'
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd"/>
EOF
      mvn -q -s $HOME/maven-settings.xml -Dmaven.repo.local=$HOME/.m2/repository -DskipTests package
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
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