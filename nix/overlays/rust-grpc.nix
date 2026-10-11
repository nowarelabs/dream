{ src }:
final: prev:
let
  inherit (prev) lib;

  rustGrpcSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/rust-grpc");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/rust-grpc");
  };

  rust-grpc = prev.rustPlatform.buildRustPackage {
    pname = "rust-grpc";
    version = "0.1.0";

    src = rustGrpcSrc;

    cargoLock = {
      lockFile = rustGrpcSrc + "/Cargo.lock";
    };

    nativeBuildInputs = [ prev.makeWrapper prev.protobuf ];

    postInstall = ''
      mv $out/bin/rust-grpc $out/bin/.rust-grpc-unwrapped
      makeWrapper $out/bin/.rust-grpc-unwrapped $out/bin/rust-grpc --set PORT "50051"
    '';

    meta = {
      description = "Rust gRPC service";
      mainProgram = "rust-grpc";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit rust-grpc;
}
