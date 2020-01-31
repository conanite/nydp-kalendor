lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nydp/kalendor/version'

Gem::Specification.new do |spec|
  spec.name          = "nydp-kalendor"
  spec.version       = Nydp::Kalendor::VERSION
  spec.authors       = ["Conan Dalton"]
  spec.email         = ["conan@conandalton.net"]
  spec.summary       = %q{nydp integration for Kalendor gem}
  spec.description   = %q{provides functions and macros to simplify date management within nydp}
  spec.homepage      = "https://github.com/conanite/nydp-kalendor"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rspec', '~> 3.1'
  spec.add_development_dependency 'rspec_numbering_formatter'

  spec.add_dependency             'nydp',     '~> 0.2'
  spec.add_dependency             'kalendor', '0.0.4'
end
