{ src }:
final: prev:
let
  inherit (prev) lib;

  scalaGrpcSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/scala-grpc");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/scala-grpc");
  };

  scala-grpc = prev.stdenv.mkDerivation {
    pname = "scala-grpc";
    version = "0.1.0";

    src = scalaGrpcSrc;

    nativeBuildInputs = [ prev.jdk prev.maven prev.scala prev.makeWrapper ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      export HOME=$(mktemp -d)
      cat > $HOME/maven-settings.xml <<'EOF'
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd"/>
EOF
      mvn -q -s $HOME/maven-settings.xml -Dmaven.repo.local=$HOME/.m2/repository -DskipTests generate-sources dependency:copy-dependencies
      mkdir -p target/classes classes
      find target/generated-sources -name '*.java' > java-sources.txt
      javac -nowarn -cp "target/dependency/*" -d target/classes @java-sources.txt
      scalac -cp "target/classes:target/dependency/*" -d classes src/main/scala/Main.scala
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/scala-grpc $out/bin
      cp -r . $out/libexec/scala-grpc/
      chmod -R u+w $out/libexec/scala-grpc
      chmod +x $out/libexec/scala-grpc/bin/* 2>/dev/null || true
      makeWrapper $out/libexec/scala-grpc/bin/scala-grpc $out/bin/scala-grpc \
        --prefix PATH : ${lib.makeBinPath [ prev.jdk ]} \
        --set PORT "50059"
      runHook postInstall
    '';

    meta = {
      description = "Scala gRPC service (grpc-java)";
      mainProgram = "scala-grpc";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit scala-grpc;
}