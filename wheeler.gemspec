# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wheeler/version'

Gem::Specification.new do |spec|
  spec.name          = "wheeler"
  spec.version       = Wheeler::VERSION
  spec.authors       = ["Scott Pierce"]
  spec.email         = ["scott.pierce@centro.net"]

  spec.summary       = %q{Wheel of Fortune solver}
  spec.homepage      = "https://github.com/ddrscott/wheeler"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"

  spec.add_dependency "treat"
end
