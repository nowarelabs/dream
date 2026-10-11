{ src }:
final: prev:
let
  inherit (prev) lib;
  elixir = prev.beamPackages.elixir;

  elixirAppSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/elixir-app");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/elixir-app");
  };

  elixir-app = prev.stdenv.mkDerivation {
    pname = "elixir-app";
    version = "0.1.0";

    src = elixirAppSrc;

    nativeBuildInputs = [ elixir prev.makeWrapper ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      export HOME=$(mktemp -d)
      export MIX_ENV=prod
      mix local.hex --force
      mix local.rebar --force
      mix deps.get --only prod
      mix release
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/elixir-app $out/bin
      cp -r . $out/libexec/elixir-app/
      chmod -R u+w $out/libexec/elixir-app
      chmod +x $out/libexec/elixir-app/bin/* 2>/dev/null || true
      makeWrapper $out/libexec/elixir-app/bin/elixir-app $out/bin/elixir-app \
        --prefix PATH : ${lib.makeBinPath [ elixir ]} \
        --set PORT "4000"
      runHook postInstall
    '';

    meta = {
      description = "Elixir service";
      mainProgram = "elixir-app";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit elixir-app;
}
