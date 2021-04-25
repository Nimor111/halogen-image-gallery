let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { };
  spago2nix = import sources.spago2nix { };
  easy-ps = import sources.easy-purescript-nix { inherit pkgs; };
in
pkgs.stdenv.mkDerivation {
  name = "purescript-bootstrap-shell";
  buildInputs = with pkgs; [
    python
    postgresql
    nodejs-12_x
    yarn
    yarn2nix
    easy-ps.purs
    easy-ps.spago
    #easy-ps.spago2nix
    nodePackages.node2nix
    spago2nix
  ];
}
