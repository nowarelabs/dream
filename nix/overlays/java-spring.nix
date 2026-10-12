{ src }:
final: prev:
let
  inherit (prev) lib;

  javaSpringSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/java-spring");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/java-spring");
  };

  java-spring = prev.stdenv.mkDerivation {
    pname = "java-spring";
    version = "0.1.0";

    src = javaSpringSrc;

    nativeBuildInputs = [ prev.jdk prev.maven prev.makeWrapper ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      export HOME=$(mktemp -d)
      cat > $HOME/maven-settings.xml <<'EOF'
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd"/>
EOF
      mvn -q -s $HOME/maven-settings.xml -Dmaven.repo.local=$HOME/.m2/repository -DskipTests package
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
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