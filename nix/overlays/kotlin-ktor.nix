{ src }:
final: prev:
let
  inherit (prev) lib;

  kotlinKtorSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/kotlin-ktor");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/kotlin-ktor");
  };

  kotlin-ktor = prev.stdenv.mkDerivation (finalAttrs: {
    pname = "kotlin-ktor";
    version = "0.1.0";

    src = kotlinKtorSrc;

    nativeBuildInputs = [ prev.jdk prev.gradle prev.makeWrapper ];

    mitmCache = prev.gradle.fetchDeps {
      pkg = finalAttrs.finalPackage;
      data = ./kotlin-ktor-deps.json;
    };

    __darwinAllowLocalNetworking = true;

    gradleBuildTask = "installDist";
    doCheck = false;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec $out/bin
      cp -r build/install/${finalAttrs.pname} $out/libexec/
      chmod -R u+w $out/libexec
      chmod +x $out/libexec/${finalAttrs.pname}/bin/* 2>/dev/null || true
      makeWrapper $out/libexec/${finalAttrs.pname}/bin/${finalAttrs.pname} $out/bin/${finalAttrs.pname} \
        --prefix PATH : ${lib.makeBinPath [ prev.jdk ]} \
        --set PORT "3027"
      runHook postInstall
    '';

    meta = {
      description = "Kotlin Ktor HTTP service";
      mainProgram = "kotlin-ktor";
      platforms = lib.platforms.unix;
    };
  });
in
{
  inherit kotlin-ktor;
}