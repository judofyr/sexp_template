# encoding: utf-8
require File.expand_path('../lib/sexp_template/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = 'sexp_template'
  spec.version       = SexpTemplate::VERSION
  spec.authors       = ['Magnus Holm']
  spec.email         = ['judofyr@gmail.com']
  spec.description   = %q{A Ruby parser written in pure Ruby.}
  spec.summary       = spec.description
  spec.homepage      = 'http://github.com/judofyr/sexp_template'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/})
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency             'ast',       '~> 1.0'
  spec.add_dependency             'parser',    '~> 1.0'

  spec.add_development_dependency 'bundler',   '~> 1.2'
  spec.add_development_dependency 'rake',      '~> 0.9'

  spec.add_development_dependency 'minitest',  '~> 4.7.0'
end
