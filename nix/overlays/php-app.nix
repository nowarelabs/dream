{ src }:
final: prev:
let
  inherit (prev) lib;
  php = prev.php83;

  phpAppSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/php-app");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/php-app");
  };

  php-app = prev.stdenv.mkDerivation {
    pname = "php-app";
    version = "0.1.0";

    src = phpAppSrc;

    nativeBuildInputs = [ php prev.makeWrapper ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/php-app $out/bin
      cp -r . $out/libexec/php-app/
      chmod -R u+w $out/libexec/php-app
      chmod +x $out/libexec/php-app/bin/* 2>/dev/null || true
      makeWrapper $out/libexec/php-app/bin/php-app $out/bin/php-app \
        --prefix PATH : ${lib.makeBinPath [ php ]} \
        --set PORT "4025"
      runHook postInstall
    '';

    meta = {
      description = "PHP built-in server HTTP service";
      mainProgram = "php-app";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit php-app;
}
