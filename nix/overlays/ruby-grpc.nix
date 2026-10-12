{ src }:
final: prev:
let
  inherit (prev) lib;
  ruby = prev.ruby_3_3;

  rubyGrpcSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/ruby-grpc");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/ruby-grpc");
  };

  ruby-grpc = prev.stdenv.mkDerivation {
    pname = "ruby-grpc";
    version = "0.1.0";

    src = rubyGrpcSrc;

    nativeBuildInputs = [ ruby prev.makeWrapper ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      export HOME=$(mktemp -d)
      mkdir -p $out/share/ruby
      export GEM_HOME=$out/share/ruby
      bundle config set --local path "$GEM_HOME"
      bundle install
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/ruby-grpc $out/bin
      cp -r . $out/libexec/ruby-grpc/
      chmod -R u+w $out/libexec/ruby-grpc
      chmod +x $out/libexec/ruby-grpc/bin/* 2>/dev/null || true
      makeWrapper $out/libexec/ruby-grpc/bin/ruby-grpc $out/bin/ruby-grpc \
        --prefix PATH : ${lib.makeBinPath [ ruby ]} \
        --set GEM_HOME "$out/share/ruby" \
        --set PORT "50052"
      runHook postInstall
    '';

    meta = {
      description = "Ruby gRPC service";
      mainProgram = "ruby-grpc";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit ruby-grpc;
}