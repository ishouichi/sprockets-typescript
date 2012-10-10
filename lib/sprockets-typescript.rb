require "sprockets"
require "sprockets/typescript/compiler"
require "sprockets/typescript/template"

Sprockets.register_engine ".ts", Sprockets::Typescript::Template
