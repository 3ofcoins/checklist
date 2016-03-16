# -*- encoding: utf-8 -*-
require File.expand_path('../lib/checklist/version', __FILE__)
require 'English'

Gem::Specification.new do |gem|
  gem.authors       = ['Maciej Pasternacki']
  gem.email         = ['maciej@pasternacki.net']
  gem.description   = 'Multi-step checklist execution'
  gem.summary       = 'Define and execute a checklist'
  gem.homepage      = 'https://github.com/3ofcoins/checklist'
  gem.licenses      = ['MIT']

  gem.files         = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'checklist'
  gem.require_paths = ['lib']
  gem.version       = Checklist::VERSION

  gem.add_dependency 'highline'
  gem.add_dependency 'locale'
  gem.add_dependency 'rainbow'

  gem.add_development_dependency 'bundler', '~> 1.3'
  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'wrong', '>= 0.7.1'
  gem.add_development_dependency 'rubocop'
end
