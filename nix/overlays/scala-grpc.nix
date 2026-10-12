{ src }:
final: prev:
let
  inherit (prev) lib;

  scalaGrpcSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/scala-grpc");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/scala-grpc");
  };

  scala-grpc = prev.maven.buildMavenPackage {
    pname = "scala-grpc";
    version = "0.1.0";

    src = scalaGrpcSrc;

    mvnHash = "sha256-tKN6IPGw4SERUEh9pBdx8OuvdE0xxMcJi6d3pJktRWc=";
    mvnGoal = "generate-sources";

    nativeBuildInputs = [ prev.jdk prev.scala prev.makeWrapper ];

    postBuild = ''
      mkdir -p target/classes target/dependency classes
      find .m2 -name '*.jar' -exec cp -n {} target/dependency/ \;
      find target/generated-sources -name '*.java' > java-sources.txt
      javac -nowarn -cp "target/dependency/*" -d target/classes @java-sources.txt
      scalac -cp "target/classes:target/dependency/*" -d classes src/main/scala/Main.scala
    '';

    installPhase = ''
      runHook preInstall
      rm -rf .m2
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
