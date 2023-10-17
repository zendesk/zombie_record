require './lib/zombie_record/version'

Gem::Specification.new do |spec|
  spec.name          = "zombie_record"
  spec.version       = ZombieRecord::VERSION
  spec.authors       = ["Daniel Schierbeck"]
  spec.email         = ["dasch@zendesk.com"]
  spec.description   = %q{Allows restoring your Active Records from the dead!}
  spec.summary       = %q{Allows restoring your Active Records from the dead!}
  spec.homepage      = "https://github.com/zendesk/zombie_record"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.7"

  spec.add_dependency "activerecord", ">= 5.2", "< 7.2"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "bump"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "timecop"
end
