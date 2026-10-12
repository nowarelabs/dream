{ src }:
final: prev:
let
  inherit (prev) lib;

  csharpGrpcSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/csharp-grpc");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/csharp-grpc");
  };

  csharp-grpc = prev.stdenv.mkDerivation {
    pname = "csharp-grpc";
    version = "0.1.0";

    src = csharpGrpcSrc;

    nativeBuildInputs = [ prev.dotnet-sdk_8 prev.protobuf prev.grpc prev.makeWrapper ];

    dontConfigure = true;
    dontConfigureNuget = true;

    buildPhase = ''
      runHook preBuild
      export HOME=$(mktemp -d)
      export DOTNET_CLI_TELEMETRY_OPTOUT=1
      export DOTNET_CLI_HOME=$HOME
      export PROTOBUF_PROTOC=${prev.protobuf}/bin/protoc
      export GRPC_PROTOC_PLUGIN=${prev.grpc}/bin/grpc_csharp_plugin
      dotnet publish -c Release -o out
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/csharp-grpc $out/bin
      cp -r out/. $out/libexec/csharp-grpc/
      cat > $out/bin/csharp-grpc <<EOF
      #!/bin/sh
      exec env PORT="\''${PORT:-50058}" ${prev.dotnet-sdk_8}/bin/dotnet $out/libexec/csharp-grpc/csharp-grpc.dll
      EOF
      chmod +x $out/bin/csharp-grpc
      runHook postInstall
    '';

    meta = {
      description = "C# Grpc.AspNetCore service";
      mainProgram = "csharp-grpc";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit csharp-grpc;
}
