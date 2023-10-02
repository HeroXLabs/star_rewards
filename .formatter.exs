[
  import_deps: [:ecto, :phoenix, :typed_struct],
  inputs: ["*.{ex,exs}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: [let: 1, return: 1],
  subdirectories: ["priv/*/migrations"]
]
