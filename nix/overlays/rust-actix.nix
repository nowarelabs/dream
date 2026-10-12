{ src }:
final: prev:
let
  inherit (prev) lib;

  rustActixSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/rust-actix");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/rust-actix");
  };

  rust-actix = prev.rustPlatform.buildRustPackage {
    pname = "rust-actix";
    version = "0.1.0";

    src = rustActixSrc;

    cargoLock = {
      lockFile = rustActixSrc + "/Cargo.lock";
    };

    nativeBuildInputs = [ prev.makeWrapper ];

    postInstall = ''
      mv $out/bin/rust-actix $out/bin/.rust-actix-unwrapped
      makeWrapper $out/bin/.rust-actix-unwrapped $out/bin/rust-actix --set PORT "3005"
    '';

    meta = {
      description = "Rust Actix-Web service";
      mainProgram = "rust-actix";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit rust-actix;
}