# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'xmms2_utils/version'

Gem::Specification.new do |spec|
  spec.name          = "xmms2_utils"
  spec.version       = Xmms2Utils::VERSION
  spec.authors       = ["Mark Watts"]
  spec.email         = ["wattsmark2015@gmail.com"]
  spec.summary       = %q{A set of utilites for working with the ruby bindings for the XMMS2 client library.}
  spec.description   = File.new("./README.md").read()
  spec.homepage      = "http://github.com/mwatts15/xmms2_utils"
  spec.license       = "MPL-2.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
