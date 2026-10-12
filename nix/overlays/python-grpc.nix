{ src }:
final: prev:
let
  inherit (prev) lib;
  python = prev.python3.withPackages (ps: [ ps.grpcio ps.grpcio-tools ]);

  pythonGrpcSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/python-grpc");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/python-grpc");
  };

  python-grpc = prev.stdenv.mkDerivation {
    pname = "python-grpc";
    version = "0.1.0";

    src = pythonGrpcSrc;

    nativeBuildInputs = [ python prev.makeWrapper ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/python-grpc $out/bin
      cp -r . $out/libexec/python-grpc/
      chmod -R u+w $out/libexec/python-grpc
      chmod +x $out/libexec/python-grpc/bin/* 2>/dev/null || true
      export HOME=$(mktemp -d)
      python -m grpc_tools.protoc \
        -I"$out/libexec/python-grpc/proto" \
        --python_out="$out/libexec/python-grpc/src" \
        --grpc_python_out="$out/libexec/python-grpc/src" \
        "$out/libexec/python-grpc/proto/echo.proto"
      makeWrapper $out/libexec/python-grpc/bin/python-grpc $out/bin/python-grpc \
        --prefix PATH : ${lib.makeBinPath [ python ]} \
        --set PORT "50062"
      runHook postInstall
    '';

    meta = {
      description = "Python gRPC service";
      mainProgram = "python-grpc";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit python-grpc;
}