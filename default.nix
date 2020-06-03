with import <nixpkgs> {};

let
  easy-ps = import (
    pkgs.fetchFromGitHub {
      owner = "justinwoo";
      repo = "easy-purescript-nix";
      rev = "d4879bfd2b595d7fbd37da1a7bea5d0361975eb3";
      sha256 = "0kzwg3mwziwx378kvbzhayy65abvk1axi12zvf2f92cs53iridwh";
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
    ${spago}/bin/spago bundle-app --no-install \
      --no-build --main Main --to dist/app.js
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
