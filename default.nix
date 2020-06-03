with import <nixpkgs> {};

let
  easy-ps = import (
    pkgs.fetchFromGitHub {
      owner = "justinwoo";
      repo = "easy-purescript-nix";
      rev = "0ba91d9aa9f7421f6bfe4895677159a8a999bf20";
      sha256 = "1baq7mmd3vjas87f0gzlq83n2l1h3dlqajjqr7fgaazpa9xgzs7q";
    }
  ) {
    inherit pkgs;
  };

  spagoPkgs = import ./spago-packages.nix { inherit pkgs; };
in
mkYarnPackage rec {
  name = "url-organizer";
  src = ./.;
  packageJSON = ./package.json;
  yarnLock = ./yarn.lock;

  nativeBuildInputs = [ easy-ps.purs nodejs-12_x ];

  postBuild = ''
    ${easy-ps.purs}/bin/purs compile "$src/**/*.purs" ${builtins.toString
      (builtins.map
        (x: ''"${x.outPath}/src/**/*.purs"'')
        (builtins.attrValues spagoPkgs.inputs))}
    cp -r $src/assets ./
    '';

  postFixup = ''
    ${easy-ps.purs}/bin/purs bundle output/*/*.js -m Main --main Main -o dist/app.js
    mkdir -p $out/dist
    cp -r dist $out/
    ln -s $out/libexec/${name}/node_modules .
    ${nodejs-12_x}/bin/node node_modules/.bin/parcel \
      build assets/*.html --out-dir $out/dist/
  '';

  meta = with stdenv.lib; {
    description = "Example for building Purescript Halogen app with Nix.";
    homepage = "https://github.com/tbenst/purescript-nix-example";
    maintainers = with maintainers; [ tbenst ];
  };
}
