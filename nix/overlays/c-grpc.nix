{ src }:
final: prev:
let
  inherit (prev) lib;

  cGrpcSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/c-grpc");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/c-grpc");
  };

  c-grpc = prev.stdenv.mkDerivation {
    pname = "c-grpc";
    version = "0.1.0";

    src = cGrpcSrc;

    nativeBuildInputs = [ prev.makeWrapper ];

    buildInputs = [ prev.grpc prev.protobuf ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      cc -O2 -o c-grpc src/main.c -lgrpc -lgpr
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp c-grpc $out/bin/c-grpc
      wrapProgram $out/bin/c-grpc --set PORT "50055"
      runHook postInstall
    '';

    meta = {
      description = "C gRPC C-core service";
      mainProgram = "c-grpc";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit c-grpc;
}
