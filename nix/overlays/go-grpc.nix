{ src }:
final: prev:
let
  inherit (prev) lib;

  goGrpcSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/go-grpc");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/go-grpc");
  };

  go-grpc = prev.buildGoModule {
    pname = "go-grpc";
    version = "0.1.0";

    src = goGrpcSrc;

    vendorHash = "sha256-KGbeZQezkqlxWqrH1ZDWhJt5U0X2EkfOkZbyZUgNzCw=";

    subPackages = [ "." ];

    nativeBuildInputs = [ prev.makeWrapper ];

    postInstall = ''
      wrapProgram $out/bin/go-grpc --set PORT "50053"
    '';

    meta = {
      description = "Go gRPC service";
      mainProgram = "go-grpc";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit go-grpc;
}