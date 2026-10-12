{ src }:
final: prev:
let
  inherit (prev) lib;

  rustAppSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/rust-app");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/rust-app");
  };

  rust-app = prev.rustPlatform.buildRustPackage {
    pname = "rust-app";
    version = "0.1.0";

    src = rustAppSrc;

    cargoLock = {
      lockFile = rustAppSrc + "/Cargo.lock";
    };

    nativeBuildInputs = [ prev.makeWrapper ];

    postInstall = ''
      mv $out/bin/rust-app $out/bin/.rust-app-unwrapped
      makeWrapper $out/bin/.rust-app-unwrapped $out/bin/rust-app --set PORT "4004"
    '';

    meta = {
      description = "Plain Rust service";
      mainProgram = "rust-app";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit rust-app;
}