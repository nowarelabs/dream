{ src }:
final: prev:
let
  inherit (prev) lib;
  php = prev.php83.withExtensions ({ enabled, all }: enabled ++ [ all.grpc ]);
  composer = prev.php83.packages.composer;

  phpGrpcSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/php-grpc");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/php-grpc");
  };

  vendor = prev.stdenv.mkDerivation {
    pname = "php-grpc-vendor";
    version = "0.1.0";

    src = phpGrpcSrc;

    nativeBuildInputs = [ php composer prev.unzip ];

    dontConfigure = true;
    dontFixup = true;

    buildPhase = ''
      runHook preBuild
      export HOME=$(mktemp -d)
      composer install --no-dev --no-interaction --no-progress --no-scripts \
        --ignore-platform-req=ext-grpc
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r vendor $out/vendor
      runHook postInstall
    '';

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-Vbn8hwyOpGJGvfUeH9ItnY3e5o/6dY9UVegOWkdSBOs=";
  };

  php-grpc = prev.stdenv.mkDerivation {
    pname = "php-grpc";
    version = "0.1.0";

    src = phpGrpcSrc;

    nativeBuildInputs = [ php prev.protobuf prev.grpc prev.makeWrapper ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      cp -r ${vendor}/vendor ./vendor
      mkdir -p gen
      protoc --proto_path=proto \
        --php_out=gen \
        --grpc_out=gen \
        --plugin=protoc-gen-grpc=${prev.grpc}/bin/grpc_php_plugin \
        --grpc_opt=generate_server \
        proto/echo.proto
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/php-grpc $out/bin
      cp -r . $out/libexec/php-grpc/
      chmod -R u+w $out/libexec/php-grpc
      chmod +x $out/libexec/php-grpc/bin/* 2>/dev/null || true
      makeWrapper $out/libexec/php-grpc/bin/php-grpc $out/bin/php-grpc \
        --prefix PATH : ${lib.makeBinPath [ php ]} \
        --set PORT "50060"
      runHook postInstall
    '';

    meta = {
      description = "PHP gRPC service";
      mainProgram = "php-grpc";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit php-grpc;
}
