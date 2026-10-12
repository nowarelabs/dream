{ src }:
final: prev:
let
  inherit (prev) lib;
  sbcl = prev.sbcl;

  lispAppSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/lisp-app");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/lisp-app");
  };

  lisp-app = prev.stdenv.mkDerivation {
    pname = "lisp-app";
    version = "0.1.0";

    src = lispAppSrc;

    nativeBuildInputs = [ sbcl prev.makeWrapper ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/lisp-app $out/bin
      cp -r . $out/libexec/lisp-app/
      chmod -R u+w $out/libexec/lisp-app
      chmod +x $out/libexec/lisp-app/bin/lisp-app

      makeWrapper $out/libexec/lisp-app/bin/lisp-app $out/bin/lisp-app \
        --prefix PATH : ${lib.makeBinPath [ sbcl ]} \
        --set PORT "4031"
      runHook postInstall
    '';

    meta = {
      description = "SBCL raw socket HTTP service";
      mainProgram = "lisp-app";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit lisp-app;
}
