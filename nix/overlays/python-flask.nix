{ src }:
final: prev:
let
  inherit (prev) lib;
  python = prev.python3.withPackages (ps: [ ps.flask ]);

  pythonFlaskSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/python-flask");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/python-flask");
  };

  python-flask = prev.stdenv.mkDerivation {
    pname = "python-flask";
    version = "0.1.0";

    src = pythonFlaskSrc;

    nativeBuildInputs = [ prev.makeWrapper ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/python-flask $out/bin
      cp -r . $out/libexec/python-flask/
      chmod -R u+w $out/libexec/python-flask
      chmod +x $out/libexec/python-flask/bin/* 2>/dev/null || true
      makeWrapper $out/libexec/python-flask/bin/python-flask $out/bin/python-flask \
        --prefix PATH : ${lib.makeBinPath [ python ]} \
        --set PORT "3028"
      runHook postInstall
    '';

    meta = {
      description = "Python Flask HTTP service";
      mainProgram = "python-flask";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit python-flask;
}
