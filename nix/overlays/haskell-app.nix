{ src }:
final: prev:
let
  inherit (prev) lib;
  haskell = prev.haskellPackages;

  haskellAppSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/haskell-app");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/haskell-app");
  };

  haskell-app = haskell.mkDerivation {
    pname = "haskell-app";
    version = "0.1.0";

    src = haskellAppSrc;

    isExecutable = true;
    executableToolDepends = [ prev.makeWrapper ];
    executableHaskellDepends = with haskell; [
      base
      bytestring
      http-types
      wai
      warp
    ];

    postInstall = ''
      wrapProgram $out/bin/haskell-app --set PORT "4033"
    '';

    license = lib.licenses.mit;
    description = "Haskell Warp/WAI HTTP service";
    mainProgram = "haskell-app";
    platforms = lib.platforms.unix;
  };
in
{
  inherit haskell-app;
}
