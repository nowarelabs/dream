{ src }:
final: prev:
let
  inherit (prev) lib;

  csharpGrpcSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/csharp-grpc");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/csharp-grpc");
  };

  csharp-grpc = prev.buildDotnetModule {
    pname = "csharp-grpc";
    version = "0.1.0";

    src = csharpGrpcSrc;

    projectFile = "csharp-grpc.csproj";
    nugetDeps = ./csharp-grpc-deps.json;
    "dotnet-sdk" = prev.dotnet-sdk_8;
    "dotnet-runtime" = prev.dotnet-aspnetcore_8;

    nativeBuildInputs = [ prev.protobuf prev.grpc ];

    preBuild = ''
      export PROTOBUF_PROTOC=${prev.protobuf}/bin/protoc
      export GRPC_PROTOC_PLUGIN=${prev.grpc}/bin/grpc_csharp_plugin
    '';

    doCheck = false;

    makeWrapperArgs = [ "--set" "PORT" "50058" ];

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