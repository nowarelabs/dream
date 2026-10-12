{ src }:
final: prev:
let
  inherit (prev) lib;

  scalaHttp4sSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/scala-http4s");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/scala-http4s");
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
      mkdir -p $out/libexec/scala-http4s $out/bin
      cp -r . $out/libexec/scala-http4s/
      chmod -R u+w $out/libexec/scala-http4s
      chmod +x $out/libexec/scala-http4s/bin/* 2>/dev/null || true
      makeWrapper $out/libexec/scala-http4s/bin/scala-http4s $out/bin/scala-http4s \
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