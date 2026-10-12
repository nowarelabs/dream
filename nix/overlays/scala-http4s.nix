{ src }:
final: prev:
let
  inherit (prev) lib;

  scalaHttp4sSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/scala-http4s");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/scala-http4s");
  };

  sbtDeps = prev.stdenv.mkDerivation {
    pname = "scala-http4s-sbt-deps";
    version = "0.1.0";

    src = scalaHttp4sSrc;

    nativeBuildInputs = [ prev.jdk prev.sbt ];

    dontConfigure = true;
    dontFixup = true;

    installPhase = ''
      runHook preInstall
      export HOME=$(mktemp -d)
      mkdir -p "$HOME/.cache/coursier" "$HOME/.sbt/boot" "$HOME/.ivy2"
      export COURSIER_CACHE="$HOME/.cache/coursier"
      sbt -batch -Dsbt.color=false \
        -Duser.home="$HOME" \
        -Dsbt.global.base="$HOME/.sbt" \
        -Dsbt.boot.directory="$HOME/.sbt/boot" \
        -Dsbt.ivy.home="$HOME/.ivy2" \
        update
      mkdir -p $out
      cp -r "$HOME/.cache/coursier/." $out/cache/
      cp -r "$HOME/.sbt/." $out/sbt/
      cp -r "$HOME/.ivy2/." $out/ivy/
      runHook postInstall
    '';

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-yS+JP4gEHxqWTx9g8shZgPw+p/j0EwaeIkJe4aL4lyo=";
  };

  scala-http4s = prev.stdenv.mkDerivation {
    pname = "scala-http4s";
    version = "0.1.0";

    src = scalaHttp4sSrc;

    nativeBuildInputs = [ prev.jdk prev.sbt prev.makeWrapper ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      export HOME=$(mktemp -d)
      mkdir -p "$HOME/.cache/coursier" "$HOME/.sbt/boot" "$HOME/.ivy2"
      cp -r ${sbtDeps}/cache/. "$HOME/.cache/coursier/"
      cp -r ${sbtDeps}/sbt/. "$HOME/.sbt/"
      cp -r ${sbtDeps}/ivy/. "$HOME/.ivy2/"
      chmod -R u+w "$HOME"
      export COURSIER_CACHE="$HOME/.cache/coursier"
      sbt -batch -Dsbt.color=false \
        -Duser.home="$HOME" \
        -Dsbt.global.base="$HOME/.sbt" \
        -Dsbt.boot.directory="$HOME/.sbt/boot" \
        -Dsbt.ivy.home="$HOME/.ivy2" \
        assembly
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec $out/bin
      cp target/scala-2.13/scala-http4s.jar $out/libexec/scala-http4s.jar
      makeWrapper ${prev.jdk}/bin/java $out/bin/scala-http4s \
        --add-flags "-jar $out/libexec/scala-http4s.jar" \
        --prefix PATH : ${lib.makeBinPath [ prev.jdk ]} \
        --set PORT "3024"
      runHook postInstall
    '';

    meta = {
      description = "Scala http4s HTTP service";
      mainProgram = "scala-http4s";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit scala-http4s;
}