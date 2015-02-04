Gem::Specification.new do |s|
  s.name = "sprockets-typescript"
  s.version = "1.0"
  s.authors = "Anton Ageev"
  s.email = "antage@gmail.com"
  s.summary = "TypeScript compiler for Sprockets"

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.add_runtime_dependency "sprockets", "~> 2.1"
  s.add_runtime_dependency "tilt"
  s.add_runtime_dependency "typescript-node", "~> 1.1"
end
