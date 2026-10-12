{ src }:
final: prev:
let
  inherit (prev) lib;
  php = prev.php83;
  composer = prev.php83.packages.composer;

  phpSlimSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/php-slim");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/php-slim");
  };

  php-slim = prev.stdenv.mkDerivation {
    pname = "php-slim";
    version = "0.1.0";

    src = phpSlimSrc;

    nativeBuildInputs = [ php composer prev.unzip prev.makeWrapper ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      export HOME=$(mktemp -d)
      composer install --no-dev --no-interaction --no-progress
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/php-slim $out/bin
      cp -r . $out/libexec/php-slim/
      chmod -R u+w $out/libexec/php-slim
      chmod +x $out/libexec/php-slim/bin/* 2>/dev/null || true
      makeWrapper $out/libexec/php-slim/bin/php-slim $out/bin/php-slim \
        --prefix PATH : ${lib.makeBinPath [ php ]} \
        --set PORT "3025"
      runHook postInstall
    '';

    meta = {
      description = "PHP Slim HTTP service";
      mainProgram = "php-slim";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit php-slim;
}
