{ src }:
final: prev:
let
  inherit (prev) lib;
  clojure = prev.clojure;
  jdk = prev.jdk;

  clojureAppSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/clojure-app");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/clojure-app");
  };

  clojure-app = prev.stdenv.mkDerivation {
    pname = "clojure-app";
    version = "0.1.0";

    src = clojureAppSrc;

    nativeBuildInputs = [ clojure jdk prev.makeWrapper ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      export HOME=$(mktemp -d)
      export JAVA_TOOL_OPTIONS="-Duser.home=$HOME"
      export CLJ_CONFIG=$HOME/.clojure
      export CLJ_CACHE=$HOME/.clojure/.cpcache

      mkdir -p $out/libexec/clojure-app $out/bin $out/lib/m2
      cp -r . $out/libexec/clojure-app/
      chmod -R u+w $out/libexec/clojure-app
      chmod +x $out/libexec/clojure-app/bin/clojure-app

      cd $out/libexec/clojure-app
      clojure -P
      cp -r $HOME/.m2/repository/. $out/lib/m2/
      find $out/lib/m2 -name '_remote.repositories' -delete
      find $out/lib/m2 -name '*.lastUpdated' -delete
      sed "1s|{|{:mvn/local-repo \"$out/lib/m2\"|" deps.edn > deps.edn.tmp
      mv deps.edn.tmp deps.edn

      makeWrapper $out/libexec/clojure-app/bin/clojure-app $out/bin/clojure-app \
        --prefix PATH : ${lib.makeBinPath [ clojure jdk ]} \
        --set PORT "4030"
      runHook postInstall
    '';

    meta = {
      description = "Bare Clojure HTTP service";
      mainProgram = "clojure-app";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit clojure-app;
}
