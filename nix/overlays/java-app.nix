{ src }:
final: prev:
let
  inherit (prev) lib;

  javaAppSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/java-app");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/java-app");
  };

  java-app = prev.stdenv.mkDerivation {
    pname = "java-app";
    version = "0.1.0";

    src = javaAppSrc;

    nativeBuildInputs = [ prev.jdk prev.makeWrapper ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      mkdir -p classes
      find src -name '*.java' > sources.txt
      javac -d classes @sources.txt
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/java-app $out/bin
      cp -r . $out/libexec/java-app/
      chmod -R u+w $out/libexec/java-app
      chmod +x $out/libexec/java-app/bin/* 2>/dev/null || true
      makeWrapper $out/libexec/java-app/bin/java-app $out/bin/java-app \
        --prefix PATH : ${lib.makeBinPath [ prev.jdk ]} \
        --set PORT "4022"
      runHook postInstall
    '';

    meta = {
      description = "Java HTTP service (JDK HttpServer)";
      mainProgram = "java-app";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit java-app;
}