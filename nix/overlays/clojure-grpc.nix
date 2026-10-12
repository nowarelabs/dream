{ src }:
final: prev:
let
  inherit (prev) lib;
  clojure = prev.clojure;
  jdk = prev.jdk;
  protobuf = prev.protobuf_25;

  clojureGrpcSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/clojure-grpc");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/clojure-grpc");
  };

  clojure-grpc = prev.stdenv.mkDerivation {
    pname = "clojure-grpc";
    version = "0.1.0";

    src = clojureGrpcSrc;

    nativeBuildInputs = [ clojure jdk protobuf prev.makeWrapper ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      export HOME=$(mktemp -d)
      export JAVA_TOOL_OPTIONS="-Duser.home=$HOME"
      export CLJ_CONFIG=$HOME/.clojure
      export CLJ_CACHE=$HOME/.clojure/.cpcache

      mkdir -p gen classes
      protoc --proto_path=proto --java_out=gen proto/echo.proto
      clojure -P
      javac -cp "$(clojure -Spath)" -d classes $(find gen -name '*.java')

      mkdir -p $out/libexec/clojure-grpc $out/bin $out/lib/m2
      cp -r . $out/libexec/clojure-grpc/
      chmod -R u+w $out/libexec/clojure-grpc
      cp -r $HOME/.m2/repository/. $out/lib/m2/
      find $out/lib/m2 -name '_remote.repositories' -delete
      find $out/lib/m2 -name '*.lastUpdated' -delete
      cd $out/libexec/clojure-grpc
      sed "1s|{|{:mvn/local-repo \"$out/lib/m2\"|" deps.edn > deps.edn.tmp
      mv deps.edn.tmp deps.edn
      chmod +x bin/clojure-grpc build.sh

      makeWrapper $out/libexec/clojure-grpc/bin/clojure-grpc $out/bin/clojure-grpc \
        --prefix PATH : ${lib.makeBinPath [ clojure jdk protobuf ]} \
        --set PORT "50063"
      runHook postInstall
    '';

    meta = {
      description = "Clojure gRPC service";
      mainProgram = "clojure-grpc";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit clojure-grpc;
}
