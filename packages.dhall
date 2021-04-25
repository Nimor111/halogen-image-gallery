let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.14.0-20210409/packages.dhall sha256:e81c2f2ce790c0e0d79869d22f7a37d16caeb5bd81cfda71d46c58f6199fd33f

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
          , "unsafe-reference"
          ]
        , repo =
            "https://github.com/spicydonuts/purescript-react-basic-hooks.git"
        , version = "d79a9b8276bcccd087ce579f708c026903755499"
        }
      }

in  upstream // overrides // additions
