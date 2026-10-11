{ src }:
final: prev:
let
  inherit (prev) lib;

  monorepoRunner = prev.stdenvNoCC.mkDerivation {
    pname = "monorepo-runner";
    version = "0.1.0";

    dontUnpack = true;

    nativeBuildInputs = [ prev.makeWrapper ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin $out/share
      cp ${src + "/Procfile"} $out/share/Procfile
      makeWrapper ${prev.foreman}/bin/foreman $out/bin/monorepo-start \
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
      description = "Monorepo orchestrator";
      mainProgram = "monorepo-start";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit monorepoRunner;
}
