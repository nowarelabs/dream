{ src }:
final: prev:
let
  inherit (prev) lib;
  ruby = prev.ruby_3_3;

  rubyAppSrc = lib.fileset.toSource {
    root = /. + builtins.unsafeDiscardStringContext (src + "/services/ruby-app");
    fileset = /. + builtins.unsafeDiscardStringContext (src + "/services/ruby-app");
  };

  rubyEnv = prev.bundlerEnv {
    name = "ruby-app-env";
    inherit ruby;
    gemfile = rubyAppSrc + "/Gemfile";
    lockfile = rubyAppSrc + "/Gemfile.lock";
    gemset = rubyAppSrc + "/gemset.nix";
  };

  gempath = "${rubyEnv}/lib/ruby/gems/3.3.0";

  ruby-app = prev.stdenv.mkDerivation {
    pname = "ruby-app";
    version = "0.1.0";

    src = rubyAppSrc;

    nativeBuildInputs = [ rubyEnv ruby prev.makeWrapper ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/ruby-app $out/bin
      cp -r . $out/libexec/ruby-app/
      chmod -R u+w $out/libexec/ruby-app
      chmod +x $out/libexec/ruby-app/bin/* 2>/dev/null || true
      makeWrapper $out/libexec/ruby-app/bin/ruby-app $out/bin/ruby-app \
        --prefix PATH : ${lib.makeBinPath [ rubyEnv ruby ]} \
        --set GEM_HOME "${gempath}" \
        --set GEM_PATH "${gempath}" \
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
