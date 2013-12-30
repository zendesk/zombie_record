# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zombie_record/version'

Gem::Specification.new do |spec|
  spec.name          = "zombie_record"
  spec.version       = ZombieRecord::VERSION
  spec.authors       = ["Daniel Schierbeck"]
  spec.email         = ["dasch@zendesk.com"]
  spec.description   = %q{Allows restoring your Active Records from the dead!}
  spec.summary       = %q{Allows restoring your Active Records from the dead!}
  spec.homepage      = "https://github.com/dasch/zombie_record"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", "~> 4.0.2"
  spec.add_dependency "mysql2"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "timecop", "~> 0.7.0"
end
