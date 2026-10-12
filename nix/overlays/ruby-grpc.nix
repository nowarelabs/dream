{ src }:
final: prev:
let
  inherit (prev) lib;
  ruby = prev.ruby_3_3;

  rubyGrpcSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/ruby-grpc");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/ruby-grpc");
  };

  rubyEnv = prev.bundlerEnv {
    name = "ruby-grpc-env";
    inherit ruby;
    gemfile = rubyGrpcSrc + "/Gemfile";
    lockfile = rubyGrpcSrc + "/Gemfile.lock";
    gemset = rubyGrpcSrc + "/gemset.nix";
  };

  gempath = "${rubyEnv}/lib/ruby/gems/3.3.0";

  ruby-grpc = prev.stdenv.mkDerivation {
    pname = "ruby-grpc";
    version = "0.1.0";

    src = rubyGrpcSrc;

    nativeBuildInputs = [ rubyEnv ruby prev.makeWrapper ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/ruby-grpc $out/bin
      cp -r . $out/libexec/ruby-grpc/
      chmod -R u+w $out/libexec/ruby-grpc
      chmod +x $out/libexec/ruby-grpc/bin/* 2>/dev/null || true
      makeWrapper $out/libexec/ruby-grpc/bin/ruby-grpc $out/bin/ruby-grpc \
        --prefix PATH : ${lib.makeBinPath [ rubyEnv ruby ]} \
        --set GEM_HOME "${gempath}" \
        --set GEM_PATH "${gempath}" \
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
