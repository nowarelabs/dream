{ src }:
final: prev:
let
  inherit (prev) lib;

  csharpAppSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/csharp-app");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/csharp-app");
  };

  csharp-app = prev.stdenv.mkDerivation {
    pname = "csharp-app";
    version = "0.1.0";

    src = csharpAppSrc;

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
      mkdir -p $out/libexec/csharp-app $out/bin
      cp -r out/. $out/libexec/csharp-app/
      cat > $out/bin/csharp-app <<EOF
      #!/bin/sh
      exec env PORT="\''${PORT:-4023}" ${prev.dotnet-sdk_8}/bin/dotnet $out/libexec/csharp-app/csharp-app.dll
      EOF
      chmod +x $out/bin/csharp-app
      runHook postInstall
    '';

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
