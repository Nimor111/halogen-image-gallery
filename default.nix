let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { };
  easy-ps = import sources.easy-purescript-nix { inherit pkgs; };
  spagoPkgs = import ./spago-packages.nix { inherit pkgs; };
in
pkgs.mkYarnPackage rec {
  name = "halogen-image-gallery";
  src = ./.;
  packageJSON = ./package.json;
  yarnLock = ./yarn.lock;

  nativeBuildInputs = [ easy-ps.purs pkgs.nodejs-12_x ];

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
    ${pkgs.nodejs-12_x}/bin/node node_modules/.bin/parcel \
      build assets/*.html --dist-dir $out/dist/
  '';

  meta = with pkgs.stdenv.lib; {
    description = "An image gallery with Pixabay search written in Halogen.";
    homepage = "https://github.com/Nimor111/halogen-image-gallery";
    maintainers = with maintainers; [ Nimor111 ];
  };
}
