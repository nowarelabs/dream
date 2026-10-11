{ src }:
final: prev:
let
  inherit (prev) lib;
  nodejs = prev.nodejs_24;

  dreamSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/dream");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/dream");
  };

  dream = prev.stdenvNoCC.mkDerivation {
    pname = "dream";
    version = "0.1.0";

    src = dreamSrc;

    nativeBuildInputs = [ prev.makeWrapper ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/dream $out/bin
      cp -r . $out/libexec/dream/
      chmod -R u+w $out/libexec/dream
      chmod +x $out/libexec/dream/bin/* 2>/dev/null || true
      makeWrapper $out/libexec/dream/bin/dream $out/bin/dream \
        --prefix PATH : ${lib.makeBinPath [ nodejs ]} \
        --set PORT "8000"
      makeWrapper $out/libexec/dream/bin/dream-dev $out/bin/dream-dev \
        --prefix PATH : ${lib.makeBinPath [ nodejs ]} \
        --set PORT "8000"
      runHook postInstall
    '';

    meta = {
      description = "Dream system server";
      mainProgram = "dream";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit dream;
}
