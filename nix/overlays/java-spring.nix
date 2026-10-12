{ src }:
final: prev:
let
  inherit (prev) lib;

  javaSpringSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/java-spring");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/java-spring");
  };

  java-spring = prev.maven.buildMavenPackage {
    pname = "java-spring";
    version = "0.1.0";

    src = javaSpringSrc;

    mvnHash = "sha256-+J4hjsiiPw9Jtw8KKUTthGrO5E+Eph8xtCi1sw8wmxU=";
    doCheck = false;

    nativeBuildInputs = [ prev.makeWrapper ];

    installPhase = ''
      runHook preInstall
      rm -rf .m2
      mkdir -p $out/libexec/java-spring $out/bin
      cp -r . $out/libexec/java-spring/
      chmod -R u+w $out/libexec/java-spring
      chmod +x $out/libexec/java-spring/bin/* 2>/dev/null || true
      makeWrapper $out/libexec/java-spring/bin/java-spring $out/bin/java-spring \
        --prefix PATH : ${lib.makeBinPath [ prev.jdk ]} \
        --set PORT "3022"
      runHook postInstall
    '';

    meta = {
      description = "Java Spring Boot HTTP service";
      mainProgram = "java-spring";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit java-spring;
}
