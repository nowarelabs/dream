{ src }:
final: prev:
let
  inherit (prev) lib;

  cppGrpcSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/cpp-grpc");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/cpp-grpc");
  };

  cpp-grpc = prev.stdenv.mkDerivation {
    pname = "cpp-grpc";
    version = "0.1.0";

    src = cppGrpcSrc;

    nativeBuildInputs = [ prev.makeWrapper prev.protobuf prev.grpc prev.pkg-config ];

    buildInputs = [ prev.grpc prev.protobuf ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      ${prev.protobuf}/bin/protoc \
        --proto_path=proto \
        --cpp_out=. \
        --grpc_out=. \
        --plugin=protoc-gen-grpc=${prev.grpc}/bin/grpc_cpp_plugin \
        proto/echo.proto
      c++ -std=c++17 -O2 -I. -o cpp-grpc src/main.cpp echo.pb.cc echo.grpc.pb.cc \
        $(pkg-config --cflags --libs grpc++ protobuf)
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp cpp-grpc $out/bin/cpp-grpc
      wrapProgram $out/bin/cpp-grpc --set PORT "50056"
      runHook postInstall
    '';

    meta = {
      description = "C++ gRPC service";
      mainProgram = "cpp-grpc";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit cpp-grpc;
}
