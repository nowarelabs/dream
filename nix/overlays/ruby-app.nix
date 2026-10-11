{ src }:
final: prev:
let
  inherit (prev) lib;
  ruby = prev.ruby_3_3;

  rubyAppSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/ruby-app");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/ruby-app");
  };

  ruby-app = prev.stdenv.mkDerivation {
    pname = "ruby-app";
    version = "0.1.0";

    src = rubyAppSrc;

    nativeBuildInputs = [ ruby prev.makeWrapper ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      export HOME=$(mktemp -d)
      export GEM_HOME=$out/share/ruby
      bundle config set --local path "$GEM_HOME"
      bundle install
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/ruby-app $out/bin $out/share
      cp -r . $out/libexec/ruby-app/
      chmod -R u+w $out/libexec/ruby-app
      chmod +x $out/libexec/ruby-app/bin/* 2>/dev/null || true
      makeWrapper $out/libexec/ruby-app/bin/ruby-app $out/bin/ruby-app \
        --prefix PATH : ${lib.makeBinPath [ ruby ]} \
        --set GEM_HOME "$out/share/ruby" \
        --set PORT "4002"
      runHook postInstall
    '';

    meta = {
      description = "Ruby service";
      mainProgram = "ruby-app";
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit ruby-app;
}
