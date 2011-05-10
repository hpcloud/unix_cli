require 'rubygems'
require 'rake'
require 'rspec/core'
require 'rspec/core/rake_task'

task :default => :spec

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = '--color'
end

namespace :spec do

  desc "Run specs verbosely"
  RSpec::Core::RakeTask.new('verbose') do |t|
    t.rspec_opts = '--color --format documentation'
  end

  desc "Run specs with html report"
  RSpec::Core::RakeTask.new('html') do |t|
    t.rspec_opts = '--color --format html'
  end
  
  desc "Run specs and generate code coverage"
  task :coverage do
    ENV['SPEC_CODE_COVERAGE'] = 'true'
    Rake::Task['spec'].invoke
  end

end

# RSpec::Core::RakeTask.new(:rcov) do |spec|
#   spec.pattern = 'spec/**/*_spec.rb'
#   spec.rcov = true
# end

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
      ENV['SPEC_CODE_COVERAGE'] = 'true'
      ENV['CI_REPORTS'] = 'ci/reports/rspec'
      gem 'ci_reporter'
      require 'ci/reporter/rake/rspec'
      rm_rf 'ci/reports/html/index.html'
      rm_rf 'coverage'
    end
  end
  
  # Hijack RSpec options with our own triple formatter.
  desc ''
  RSpec::Core::RakeTask.new('spec:special') do |t|
    t.rspec_opts = %Q{--color --require "#{File.dirname(__FILE__)}/ci/triple_formatter.rb"}
  end
end

require 'yard'
YARD::Rake::YardocTask.new
