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
  
  desc "Run specs with html report"
  RSpec::Core::RakeTask.new('unit') do |t|
    t.rspec_opts = '--color'
    t.pattern = 'spec/unit/'
  end
  
  desc "Run specs and generate code coverage"
  task :coverage do
    ENV['SPEC_CODE_COVERAGE'] = 'true'
    Rake::Task['spec'].invoke
  end

end

desc "Run specs with reports output for Jenkins"
namespace :jenkins do
  
#  namespace :setup do
#    task :rspec => [:pre_ci, 'ci:setup:rspec']
#    task :pre_ci do
#      ENV['SPEC_CODE_COVERAGE'] = 'true'
#      ENV['CI_REPORTS'] = 'jenkins/reports/rspec'
#      gem 'ci_reporter'
#      require 'ci/reporter/rake/rspec'
#      rm_rf 'jenkins/reports/html/index.html'
#      rm_rf 'coverage'
#    end
#  end

  files = FileList['spec/integration/commands/**/*rb']
  files.each do |test|
    prerequisite = "pre #{test}"
    task prerequisite do
      puts "==== #{test} ===="
      @start_time = Time.now
    end
    rspectest = "rspec #{test}"
    task = RSpec::Core::RakeTask.new(rspectest) do |t|
      t.pattern = test
      t.fail_on_error = false
      t.rspec_opts = %Q{--color --require "#{File.dirname(__FILE__)}/jenkins/triple_formatter.rb"}
    end
    task test => [ prerequisite, rspectest ] do
      puts "==== #{test} ====".gsub(/./, '=') + ' ' + (Time.now - @start_time).to_s
    end
  end

  task :spec => files
  
end

require 'yard'
YARD::Rake::YardocTask.new
