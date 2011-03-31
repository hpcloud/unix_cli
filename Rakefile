require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development, :ci)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "hpcloud"
  gem.homepage = ""
  gem.license = "MIT"
  gem.summary = %Q{TODO: one-line summary of your gem}
  gem.description = %Q{TODO: longer description of your gem}
  gem.email = "matt.sanders@hp.com"
  gem.authors = ["Matt Sanders"]
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  #  gem.add_runtime_dependency 'jabber4r', '> 0.1'
  #  gem.add_development_dependency 'rspec', '> 1.2.3'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
namespace :spec do
  desc "Run specs"
  RSpec::Core::RakeTask.new do |t|
    t.rspec_opts = '--color'
  end

  desc "Run specs verbosely"
  RSpec::Core::RakeTask.new('verbose') do |t|
    t.rspec_opts = '--color --format documentation'
  end

  desc "Run specs with html report"
  RSpec::Core::RakeTask.new('html') do |t|
    t.rspec_opts = '--color --format html'
  end

end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => 'spec:spec'

require 'yard'
YARD::Rake::YardocTask.new

desc "Run specs with reports output for Jenkins"
namespace :jenkins do
  task :spec => ['jenkins:setup:rspec'] do
    #puts "SPEC_OPTS => #{ENV['SPEC_OPTS']}"
    ENV['SPEC_OPTS'] = ''
    Rake::Task['jenkins:spec:special'].invoke
  end
  
  namespace :setup do
    task :rspec => [:pre_ci, 'ci:setup:rspec']
    task :pre_ci do
      ENV["CI_REPORTS"] = 'ci/reports/rspec'
      gem 'ci_reporter'
      require 'ci/reporter/rake/rspec'
      rm_rf 'ci/reports/html/index.html'
    end
  end
  
  # Hijack RSpec options with our own triple formatter.
  desc ''
  RSpec::Core::RakeTask.new('spec:special') do |t|
    t.rspec_opts = %Q{--color --require "#{File.dirname(__FILE__)}/ci/triple_formatter.rb"}
  end
end