{ src }:
final: prev:
let
  inherit (prev) lib;

  csharpAppSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/csharp-app");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/csharp-app");
  };

  csharp-app = prev.buildDotnetModule {
    pname = "csharp-app";
    version = "0.1.0";

    src = csharpAppSrc;

    projectFile = "csharp-app.csproj";
    nugetDeps = ./csharp-app-deps.json;
    "dotnet-sdk" = prev.dotnet-sdk_8;

    doCheck = false;

    makeWrapperArgs = [ "--set" "PORT" "4023" ];

    meta = {
      description = "C# System.Net.HttpListener service";
      mainProgram = "csharp-app";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit csharp-app;
}