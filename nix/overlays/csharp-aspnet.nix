{ src }:
final: prev:
let
  inherit (prev) lib;

  csharpAspnetSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/csharp-aspnet");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/csharp-aspnet");
  };

  csharp-aspnet = prev.stdenv.mkDerivation {
    pname = "csharp-aspnet";
    version = "0.1.0";

    src = csharpAspnetSrc;

    nativeBuildInputs = [ prev.dotnet-sdk_8 prev.makeWrapper ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      export HOME=$(mktemp -d)
      export DOTNET_CLI_TELEMETRY_OPTOUT=1
      export DOTNET_CLI_HOME=$HOME
      dotnet publish -c Release -o out
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/csharp-aspnet $out/bin
      cp -r out/. $out/libexec/csharp-aspnet/
      cat > $out/bin/csharp-aspnet <<EOF
      #!/bin/sh
      exec env PORT="\''${PORT:-3023}" ${prev.dotnet-sdk_8}/bin/dotnet $out/libexec/csharp-aspnet/csharp-aspnet.dll
      EOF
      chmod +x $out/bin/csharp-aspnet
      runHook postInstall
    '';

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
