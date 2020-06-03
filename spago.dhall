{ name = "url_organizer"
, dependencies = [
    "console",
    "effect",
    "psci-support",
    "random",
    "halogen",
    "affjax",
    "simple-json"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
