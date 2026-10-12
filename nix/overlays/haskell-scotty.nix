{ src }:
final: prev:
let
  inherit (prev) lib;
  haskell = prev.haskellPackages;

  haskellScottySrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/haskell-scotty");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/haskell-scotty");
  };

  haskell-scotty = haskell.mkDerivation {
    pname = "haskell-scotty";
    version = "0.1.0";

    src = haskellScottySrc;

    isExecutable = true;
    executableToolDepends = [ prev.makeWrapper ];
    executableHaskellDepends = with haskell; [
      base
      scotty
      text
    ];

    postInstall = ''
      wrapProgram $out/bin/haskell-scotty --set PORT "3033"
    '';

    license = lib.licenses.mit;
    description = "Haskell Scotty HTTP service";
    mainProgram = "haskell-scotty";
    platforms = lib.platforms.unix;
  };
in
{
  inherit haskell-scotty;
}
