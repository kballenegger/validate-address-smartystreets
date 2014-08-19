# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'validate/address/smartystreets/version'

Gem::Specification.new do |spec|
  spec.name          = 'validate-address-smartystreets'
  spec.version       = Validate::Address::SmartyStreets::VERSION
  spec.authors       = ['Kenneth Ballenegger']
  spec.email         = ['kenneth@ballenegger.com']
  spec.summary       = %q{Verify addresses using SmartyStreets}
  spec.description   = %q{Verify addresses using SmartyStreets}
  spec.homepage      = 'https://github.com/kballenegger/validate-address-smartystreets'
  spec.license       = 'http://license.azuretalon.com'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'smarty_streets'
  spec.add_dependency 'validate'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
end
