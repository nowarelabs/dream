{ src }:
final: prev:
let
  inherit (prev) lib;

  cppAppSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/cpp-app");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/cpp-app");
  };

  cpp-app = prev.stdenv.mkDerivation {
    pname = "cpp-app";
    version = "0.1.0";

    src = cppAppSrc;

    nativeBuildInputs = [ prev.makeWrapper ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      c++ -std=c++17 -O2 -o cpp-app src/main.cpp
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp cpp-app $out/bin/cpp-app
      wrapProgram $out/bin/cpp-app --set PORT "4021"
      runHook postInstall
    '';

    meta = {
      description = "C++ raw-socket HTTP service";
      mainProgram = "cpp-app";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit cpp-app;
}
