{ src }:
final: prev:
let
  inherit (prev) lib;
  ruby = prev.ruby_3_3;

  railsAppSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/rails-app");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/rails-app");
  };

  rubyEnv = prev.bundlerEnv {
    name = "rails-app-env";
    inherit ruby;
    gemfile = railsAppSrc + "/Gemfile";
    lockfile = railsAppSrc + "/Gemfile.lock";
    gemset = railsAppSrc + "/gemset.nix";
  };

  gempath = "${rubyEnv}/lib/ruby/gems/3.3.0";

  rails-app = prev.stdenv.mkDerivation {
    pname = "rails-app";
    version = "0.1.0";

    src = railsAppSrc;

    nativeBuildInputs = [ rubyEnv ruby prev.makeWrapper ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/rails-app $out/bin
      cp -r . $out/libexec/rails-app/
      chmod -R u+w $out/libexec/rails-app
      chmod +x $out/libexec/rails-app/bin/* 2>/dev/null || true
      makeWrapper $out/libexec/rails-app/bin/rails-app $out/bin/rails-app \
        --prefix PATH : ${lib.makeBinPath [ rubyEnv ruby ]} \
        --set GEM_HOME "${gempath}" \
        --set GEM_PATH "${gempath}" \
        --set RAILS_ENV "production" \
        --set PORT "3001"
      runHook postInstall
    '';

    meta = {
      description = "Rails service";
      mainProgram = "rails-app";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit rails-app;
}
