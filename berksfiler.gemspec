# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'berksfiler/version'

Gem::Specification.new do |spec|
  spec.name          = "berksfiler"
  spec.version       = Berksfiler::VERSION
  spec.authors       = ["Matt Greensmith"]
  spec.email         = ["matt@mttgreensmith.net"]
  spec.summary       = %q{Programatically generates Berksfiles for Chef cookbooks.}
  spec.description   = %q{Programatically generates Berksfiles for Chef cookbooks.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "berkshelf"
  spec.add_dependency "configurability"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
