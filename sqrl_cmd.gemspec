# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sqrl/cmd/version'

Gem::Specification.new do |spec|
  spec.name          = "sqrl_cmd"
  spec.version       = SqrlCmd::VERSION
  spec.authors       = ["Justin Love"]
  spec.email         = ["git@JustinLove.name"]
  spec.description   = %q{Command line client for sqrl_auth}
  spec.summary       = %q{Command line client for sqrl_auth}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "sqrl_auth"
  spec.add_runtime_dependency "thor"
  spec.add_runtime_dependency "httpclient"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
