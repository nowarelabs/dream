{ src }:
final: prev:
let
  inherit (prev) lib;

  csharpAspnetSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/csharp-aspnet");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/csharp-aspnet");
  };

  csharp-aspnet = prev.buildDotnetModule {
    pname = "csharp-aspnet";
    version = "0.1.0";

    src = csharpAspnetSrc;

    projectFile = "csharp-aspnet.csproj";
    nugetDeps = ./csharp-aspnet-deps.json;
    "dotnet-sdk" = prev.dotnet-sdk_8;
    "dotnet-runtime" = prev.dotnet-aspnetcore_8;

    doCheck = false;

    makeWrapperArgs = [ "--set" "PORT" "3023" ];

    meta = {
      description = "ASP.NET Core minimal API service";
      mainProgram = "csharp-aspnet";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit csharp-aspnet;
}