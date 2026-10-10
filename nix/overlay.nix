# Project overlay. Applied from flake.nix as:
#   (import ./nix/overlay.nix { src = self; })
#
# `src` is the flake source; the overlay adds a `dream` package that bundles
# the launchers and server source and runs them with the pinned Node.js.
{
  src,
}:
final: prev:
let
  inherit (prev) lib;
  nodejs = prev.nodejs_24;

  dreamSrc = lib.cleanSourceWith {
    inherit src;
    filter =
      path: type:
      let
        base = baseNameOf (toString path);
      in
      !builtins.elem base [
        ".direnv"
        ".git"
        "nix"
        "result"
      ];
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

      if [ -d bin ]; then cp -r bin $out/libexec/dream/; fi
      if [ -d src ]; then cp -r src $out/libexec/dream/; fi
      if [ -f package.json ]; then cp package.json $out/libexec/dream/; fi

      chmod -R u+w $out/libexec/dream

      if [ -d $out/libexec/dream/bin ]; then
        chmod +x $out/libexec/dream/bin/*
        makeWrapper $out/libexec/dream/bin/dream $out/bin/dream \
          --prefix PATH : ${lib.makeBinPath [ nodejs ]}
        makeWrapper $out/libexec/dream/bin/dream-dev $out/bin/dream-dev \
          --prefix PATH : ${lib.makeBinPath [ nodejs ]}
      fi

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
