{ src }:
final: prev:
let
  inherit (prev) lib;

  scalaAppSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/scala-app");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/scala-app");
  };

  scala-app = prev.stdenv.mkDerivation {
    pname = "scala-app";
    version = "0.1.0";

    src = scalaAppSrc;

    nativeBuildInputs = [ prev.jdk prev.scala prev.makeWrapper ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      mkdir -p classes
      scalac -d classes src/Main.scala
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/scala-app $out/bin
      cp -r . $out/libexec/scala-app/
      chmod -R u+w $out/libexec/scala-app
      chmod +x $out/libexec/scala-app/bin/* 2>/dev/null || true
      makeWrapper $out/libexec/scala-app/bin/scala-app $out/bin/scala-app \
        --prefix PATH : ${lib.makeBinPath [ prev.jdk prev.scala ]} \
        --set PORT "4024"
      runHook postInstall
    '';

    meta = {
      description = "Scala HTTP service (JDK HttpServer)";
      mainProgram = "scala-app";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit scala-app;
}