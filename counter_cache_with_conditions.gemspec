# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "counter_cache_with_conditions"
  spec.version       = "0.9.0"
  spec.authors       = ["Sergey Kojin"]
  spec.email         = ["sergey.kojin@gmail.com"]
  spec.description   = %q{Replacement for ActiveRecord belongs_to :counter_cache with ability to specify conditions.}
  spec.summary       = %q{ActiveRecord counter_cache with conditions.}
  spec.homepage      = "https://github.com/skojin/counter_cache_with_conditions"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
