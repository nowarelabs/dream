{ src }:
final: prev:
let
  inherit (prev) lib;
  ruby = prev.ruby_3_3;

  railsAppSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/rails-app");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/rails-app");
  };

  rails-app = prev.stdenv.mkDerivation {
    pname = "rails-app";
    version = "0.1.0";

    src = railsAppSrc;

    nativeBuildInputs = [ ruby prev.makeWrapper ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      export HOME=$(mktemp -d)
      export RAILS_ENV=production
      export SECRET_KEY_BASE="build-only-dummy-secret"
      export GEM_HOME=$out/share/ruby
      bundle config set --local path "$GEM_HOME"
      bundle config set --local without "development test"
      bundle install
      bundle exec rails assets:precompile || true
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/rails-app $out/bin $out/share
      cp -r . $out/libexec/rails-app/
      chmod -R u+w $out/libexec/rails-app
      chmod +x $out/libexec/rails-app/bin/* 2>/dev/null || true
      makeWrapper $out/libexec/rails-app/bin/rails-app $out/bin/rails-app \
        --prefix PATH : ${lib.makeBinPath [ ruby ]} \
        --set GEM_HOME "$out/share/ruby" \
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
