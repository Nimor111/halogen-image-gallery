{ name = "url_organizer"
, dependencies =
  [ "aff"
  , "affjax"
  , "bifunctors"
  , "console"
  , "effect"
  , "either"
  , "halogen"
  , "maybe"
  , "newtype"
  , "prelude"
  , "psci-support"
  , "simple-json"
  , "strings"
  , "transformers"
  , "web-events"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
