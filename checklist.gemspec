# -*- encoding: utf-8 -*-
require File.expand_path('../lib/checklist/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Maciej Pasternacki"]
  gem.email         = ["maciej@pasternacki.net"]
  gem.description   = 'Multi-step checklist execution'
  gem.summary       = 'Define and execute a checklist'
  gem.homepage      = "https://github.com/3ofcoins/checklist"
  gem.licenses      = ['MIT']

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "checklist"
  gem.require_paths = ["lib"]
  gem.version       = Checklist::VERSION

  gem.add_dependency "formatador"
  gem.add_dependency "locale"
  gem.add_dependency "must_be"

  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'rspec'
end
