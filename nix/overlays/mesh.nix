{ src }:
final: prev:
let
  inherit (prev) lib;

  mesh = prev.stdenvNoCC.mkDerivation {
    pname = "mesh";
    version = "0.1.0";

    dontUnpack = true;

    nativeBuildInputs = [ prev.makeWrapper ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin $out/share
      cp ${src + "/Procfile"} $out/share/Procfile
      makeWrapper ${prev.foreman}/bin/foreman $out/bin/mesh \
        --add-flags "start -f $out/share/Procfile" \
        --prefix PATH : ${
          lib.makeBinPath [
            final.dream
            final.node-app
            final.next-app
            final.react-app
            final.ruby-app
            final.rails-app
            final.go-app
            final.elixir-app
            final.rust-grpc
          ]
        }
      runHook postInstall
    '';

    meta = {
      description = "Polyglot monorepo mesh";
      mainProgram = "mesh";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit mesh;
}
