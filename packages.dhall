let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.13.6-20200123/packages.dhall sha256:687bb9a2d38f2026a89772c47390d02939340b01e31aaa22de9247eadd64af05

let overrides = {=}

let additions =
  { react-basic-hooks =
    { dependencies =
        [ "aff"
        , "aff-promise"
        , "console"
        , "effect"
        , "indexed-monad"
        , "prelude"
        , "psci-support"
        , "react-basic"
        , "unsafe-reference" ]
    , repo = 
        "https://github.com/spicydonuts/purescript-react-basic-hooks.git"
    , version = 
        "d79a9b8276bcccd087ce579f708c026903755499"
    }
  }

in  upstream // overrides // additions
