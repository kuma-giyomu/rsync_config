# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rsync_config/version'

Gem::Specification.new do |spec|
  spec.name          = "rsync_config"
  spec.version       = RsyncConfig::VERSION
  spec.authors       = ["Guillaume Bodi"]
  spec.email         = ["bodi.giyomu@gmail.com"]
  spec.description   = %q{Utility gem to manage rsyncd config files}
  spec.summary       = %q{Utility gem to manage rsyncd config files}
  spec.homepage      = ""
  spec.license       = "GPLv3"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "test-unit"
  spec.add_development_dependency "debugger"
	
	spec.add_dependency 'treetop', '~>1.4.14'
end
