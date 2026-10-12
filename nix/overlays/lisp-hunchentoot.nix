{ src }:
final: prev:
let
  inherit (prev) lib;
  sbcl = prev.sbcl;

  lispHunchentootSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/lisp-hunchentoot");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/lisp-hunchentoot");
  };

  lisp-hunchentoot = prev.stdenv.mkDerivation {
    pname = "lisp-hunchentoot";
    version = "0.1.0";

    src = lispHunchentootSrc;

    nativeBuildInputs = [ sbcl prev.curl prev.cacert prev.makeWrapper ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      export HOME=$(mktemp -d)
      export SSL_CERT_FILE=${prev.cacert}/etc/ssl/certs/ca-bundle.crt
      export NIX_SSL_CERT_FILE=${prev.cacert}/etc/ssl/certs/ca-bundle.crt
      curl -fsSL https://beta.quicklisp.org/quicklisp.lisp -o "$HOME/quicklisp.lisp"
      sbcl --non-interactive --load bootstrap.lisp
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin $out/libexec/lisp-hunchentoot
      cp lisp-hunchentoot.core $out/libexec/lisp-hunchentoot/lisp-hunchentoot.core
      printf '%s\n' \
        '#!/bin/sh' \
        'export PORT="''${PORT:-3031}"' \
        'exec ${sbcl}/bin/sbcl --core ${placeholder "out"}/libexec/lisp-hunchentoot/lisp-hunchentoot.core "$@"' \
        > $out/bin/lisp-hunchentoot
      chmod +x $out/bin/lisp-hunchentoot
      runHook postInstall
    '';

    meta = {
      description = "SBCL Hunchentoot HTTP service";
      mainProgram = "lisp-hunchentoot";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit lisp-hunchentoot;
}
