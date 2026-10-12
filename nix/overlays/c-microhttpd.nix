{ src }:
final: prev:
let
  inherit (prev) lib;

  cMicrohttpdSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/c-microhttpd");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/c-microhttpd");
  };

  c-microhttpd = prev.stdenv.mkDerivation {
    pname = "c-microhttpd";
    version = "0.1.0";

    src = cMicrohttpdSrc;

    nativeBuildInputs = [ prev.makeWrapper ];

    buildInputs = [ prev.libmicrohttpd ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      cc -O2 -o c-microhttpd src/main.c -lmicrohttpd
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp c-microhttpd $out/bin/c-microhttpd
      wrapProgram $out/bin/c-microhttpd --set PORT "3020"
      runHook postInstall
    '';

    meta = {
      description = "C libmicrohttpd HTTP service";
      mainProgram = "c-microhttpd";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit c-microhttpd;
}
