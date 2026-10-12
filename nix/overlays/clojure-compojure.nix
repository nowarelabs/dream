{ src }:
final: prev:
let
  inherit (prev) lib;
  clojure = prev.clojure;
  jdk = prev.jdk;

  clojureCompojureSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/clojure-compojure");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/clojure-compojure");
  };

  m2 = prev.stdenv.mkDerivation {
    pname = "clojure-compojure-m2";
    version = "0.1.0";

    src = clojureCompojureSrc;

    nativeBuildInputs = [ clojure jdk ];

    dontConfigure = true;
    dontFixup = true;

    installPhase = ''
      runHook preInstall
      export HOME=$(mktemp -d)
      export JAVA_TOOL_OPTIONS="-Duser.home=$HOME"
      export CLJ_CONFIG=$HOME/.clojure
      export CLJ_CACHE=$HOME/.clojure/.cpcache
      clojure -P
      mkdir -p $out
      cp -r $HOME/.m2/repository/. $out/
      find $out -name '_remote.repositories' -delete
      find $out -name '*.lastUpdated' -delete
      runHook postInstall
    '';

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-Dvw889rrlkZXwVxLIp2cHe66Acm7bkEwManJwaGNvug=";
  };

  clojure-compojure = prev.stdenv.mkDerivation {
    pname = "clojure-compojure";
    version = "0.1.0";

    src = clojureCompojureSrc;

    nativeBuildInputs = [ clojure jdk prev.makeWrapper ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/clojure-compojure $out/bin $out/lib/m2
      cp -r . $out/libexec/clojure-compojure/
      chmod -R u+w $out/libexec/clojure-compojure
      chmod +x $out/libexec/clojure-compojure/bin/clojure-compojure
      cp -r ${m2}/. $out/lib/m2/

      cd $out/libexec/clojure-compojure
      sed "1s|{|{:mvn/local-repo \"$out/lib/m2\"|" deps.edn > deps.edn.tmp
      mv deps.edn.tmp deps.edn

      makeWrapper $out/libexec/clojure-compojure/bin/clojure-compojure $out/bin/clojure-compojure \
        --prefix PATH : ${lib.makeBinPath [ clojure jdk ]} \
        --set PORT "3030"
      runHook postInstall
    '';

    meta = {
      description = "Clojure Ring/Jetty Compojure HTTP service";
      mainProgram = "clojure-compojure";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit clojure-compojure;
}
