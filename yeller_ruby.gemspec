# coding: utf-8
Gem::Specification.new do |spec|
  spec.name          = "yeller_ruby"
  spec.version       = "0.0.2"
  spec.authors       = ["Tom Crayford"]
  spec.email         = ["tcrayford@googlemail.com"]
  spec.summary       = %q{A Ruby/Rack/Rails client for yellerapp.com}
  spec.description   = %q{A Ruby/Rack/Rails client for yellerapp.com}
  spec.homepage      = "https://github.com/tcrayford/yeller_rubby"
  spec.license       = "MIT"

  spec.files         = `git ls-files lib`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_runtime_dependency "yajl-ruby", "1.2.0"
end
