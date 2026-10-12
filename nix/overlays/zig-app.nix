{ src }:
final: prev:
let
  inherit (prev) lib;

  zigAppSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/zig-app");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/zig-app");
  };

  zig-app = prev.stdenv.mkDerivation {
    pname = "zig-app";
    version = "0.1.0";

    src = zigAppSrc;

    nativeBuildInputs = [ prev.zig_0_14 prev.makeWrapper ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      export ZIG_GLOBAL_CACHE_DIR=$(mktemp -d)
      export ZIG_LOCAL_CACHE_DIR=$(mktemp -d)
      zig build-exe src/main.zig -O ReleaseSafe -femit-bin=zig-app
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp zig-app $out/bin/zig-app
      wrapProgram $out/bin/zig-app --set PORT "4026"
      runHook postInstall
    '';

    meta = {
      description = "Zig std.net HTTP service";
      mainProgram = "zig-app";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit zig-app;
}
