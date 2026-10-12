{ src }:
final: prev:
let
  inherit (prev) lib;

  goGinSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/go-gin");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/go-gin");
  };

  go-gin = prev.buildGoModule {
    pname = "go-gin";
    version = "0.1.0";

    src = goGinSrc;

    vendorHash = "sha256-Ef2XLxGq8TO3WVh9EvLE30Is2CBwH4pqXxkq1tcuR0Q=";

    subPackages = [ "." ];

    nativeBuildInputs = [ prev.makeWrapper ];

    postInstall = ''
      wrapProgram $out/bin/go-gin --set PORT "3004"
    '';

    meta = {
      description = "Go Gin HTTP service";
      mainProgram = "go-gin";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit go-gin;
}