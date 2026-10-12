{ src }:
final: prev:
let
  inherit (prev) lib;
  r = prev.rWrapper.override { packages = [ prev.rPackages.plumber ]; };

  rPlumberSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/r-plumber");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/r-plumber");
  };

  r-plumber = prev.stdenv.mkDerivation {
    pname = "r-plumber";
    version = "0.1.0";

    src = rPlumberSrc;

    nativeBuildInputs = [ r prev.makeWrapper ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/r-plumber $out/bin
      cp -r . $out/libexec/r-plumber/
      chmod -R u+w $out/libexec/r-plumber
      chmod +x $out/libexec/r-plumber/bin/* 2>/dev/null || true
      makeWrapper $out/libexec/r-plumber/bin/r-plumber $out/bin/r-plumber \
        --prefix PATH : ${lib.makeBinPath [ r ]} \
        --set PORT "3029"
      runHook postInstall
    '';

    meta = {
      description = "R plumber HTTP service";
      mainProgram = "r-plumber";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit r-plumber;
}
