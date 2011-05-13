# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'scalene/version'

Gem::Specification.new do |s|
  
  s.name      = 'scalene'
  s.version   = HP::Scalene::VERSION
  # s.date      = '2011-04-05'

  s.summary       = 'HP Scalene CLI'
  s.description   = 'Useful command-line tools for managing your HP Scalene services'
  
  s.authors   = ["Matt Sanders"]
  s.email     = 'matt.sanders@hp.com'
  # s.homepage  = '' #TODO
  # s.licenses = [""]
  
  s.executables         = ["scalene"]
  s.required_ruby_version = '>= 1.8.5'
  s.required_rubygems_version = '>= 1.2.0'
  
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.5.0}
  
  s.files = Dir.glob("{bin,lib}/**/**/*") + %w(LICENSE README.rdoc CHANGELOG)
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  
  # Dependencies, this syntax requires RubyGems > 1.2.0
  s.add_runtime_dependency 'thor', '~>0.14.6'
  s.add_runtime_dependency 'hpfog', '~>0.0.6'
  s.add_development_dependency 'rspec', '~>2.4.0'
  
end

