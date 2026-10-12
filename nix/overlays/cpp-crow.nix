{ src }:
final: prev:
let
  inherit (prev) lib;

  cppCrowSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/cpp-crow");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/cpp-crow");
  };

  cpp-crow = prev.stdenv.mkDerivation {
    pname = "cpp-crow";
    version = "0.1.0";

    src = cppCrowSrc;

    nativeBuildInputs = [ prev.makeWrapper ];

    buildInputs = [ prev.crow ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      c++ -std=c++17 -O2 -o cpp-crow src/main.cpp -lpthread
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp cpp-crow $out/bin/cpp-crow
      wrapProgram $out/bin/cpp-crow --set PORT "3021"
      runHook postInstall
    '';

    meta = {
      description = "C++ Crow HTTP service";
      mainProgram = "cpp-crow";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit cpp-crow;
}
