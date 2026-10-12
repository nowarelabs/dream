{ src }:
final: prev:
let
  inherit (prev) lib;
  r = prev.rWrapper.override { packages = [ prev.rPackages.httpuv ]; };

  rAppSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/r-app");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/r-app");
  };

  r-app = prev.stdenv.mkDerivation {
    pname = "r-app";
    version = "0.1.0";

    src = rAppSrc;

    nativeBuildInputs = [ r prev.makeWrapper ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/r-app $out/bin
      cp -r . $out/libexec/r-app/
      chmod -R u+w $out/libexec/r-app
      chmod +x $out/libexec/r-app/bin/* 2>/dev/null || true
      makeWrapper $out/libexec/r-app/bin/r-app $out/bin/r-app \
        --prefix PATH : ${lib.makeBinPath [ r ]} \
        --set PORT "4029"
      runHook postInstall
    '';

    meta = {
      description = "R httpuv HTTP service";
      mainProgram = "r-app";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit r-app;
}
