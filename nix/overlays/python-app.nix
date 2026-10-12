{ src }:
final: prev:
let
  inherit (prev) lib;
  python = prev.python3;

  pythonAppSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/python-app");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/python-app");
  };

  python-app = prev.stdenv.mkDerivation {
    pname = "python-app";
    version = "0.1.0";

    src = pythonAppSrc;

    nativeBuildInputs = [ python prev.makeWrapper ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/python-app $out/bin
      cp -r . $out/libexec/python-app/
      chmod -R u+w $out/libexec/python-app
      chmod +x $out/libexec/python-app/bin/* 2>/dev/null || true
      makeWrapper $out/libexec/python-app/bin/python-app $out/bin/python-app \
        --prefix PATH : ${lib.makeBinPath [ python ]} \
        --set PORT "4028"
      runHook postInstall
    '';

    meta = {
      description = "Python standard library HTTP service";
      mainProgram = "python-app";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit python-app;
}
