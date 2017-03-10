# coding: utf-8

Gem::Specification.new do |s|
  s.name          = "counter_cache_with_conditions"
  s.version       = "0.9.2"
  s.authors       = ["Sergey Kojin"]
  s.email         = ["sergey.kojin@gmail.com"]
  s.description   = %q{Replacement for ActiveRecord belongs_to :counter_cache with ability to specify conditions.}
  s.summary       = %q{ActiveRecord counter_cache with conditions.}
  s.homepage      = "https://github.com/skojin/counter_cache_with_conditions"
  s.license       = "MIT"

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_dependency "activerecord",  '>= 3.2'
end
