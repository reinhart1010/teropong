teropong_sources = [
  'main.vala',
]

teropong_deps = [
  dependency('glib-2.0'),
  dependency('gobject-2.0'),
]

executable('teropong', teropong_sources,
  vala_args: '--target-glib=2.58',  dependencies: teropong_deps,
  install: true,
)

