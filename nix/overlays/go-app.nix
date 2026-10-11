{ src }:
final: prev:
let
  inherit (prev) lib;

  goAppSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/go-app");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/go-app");
  };

  go-app = prev.buildGoModule {
    pname = "go-app";
    version = "0.1.0";

    src = goAppSrc;

    vendorHash = null;

    nativeBuildInputs = [ prev.makeWrapper ];

    postInstall = ''
      mv $out/bin/go-app $out/bin/.go-app-unwrapped
      makeWrapper $out/bin/.go-app-unwrapped $out/bin/go-app --set PORT "8080"
    '';

    meta = {
      description = "Go service";
      mainProgram = "go-app";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit go-app;
}
