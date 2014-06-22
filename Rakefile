require 'rubygems'
require 'rake'
require 'rspec/core'
require 'rspec/core/rake_task'
require 'date'
require File.dirname(__FILE__) + '/lib/hpcloud/version'

## Helpers
def name
  @name ||= Dir['*.gemspec'].first.split('.').first
end

def version
  HP::Cloud::VERSION
end

def date
  Date.today.to_s
end

def gemspec_file
  "#{name}.gemspec"
end

def gem_file
  "#{name}-#{version}.gem"
end

def replace_header(head, header_name)
  head.sub!(/(\.#{header_name}\s*= ').*'/) { "#{$1}#{send(header_name)}'"}
end

task :default => :spec

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = '--color'
end

desc "Run before pushing out the code"
task :validate do
  libfiles = Dir['lib/*'] - ["lib/#{name}.rb", "lib/#{name}", "lib/monkey"]
  unless libfiles.empty?
    puts "Directory `lib` should only contain a `#{name}.rb` file and `#{name}` dir."
    exit!
  end
  unless Dir['VERSION*'].empty?
    puts "A `VERSION` file at root level violates Gem best practices."
    exit!
  end
end

desc "Updates the gemspec and runs 'validate'"
task :gemspec => :validate do
  # read spec file and split out manifest section
  spec = File.read(gemspec_file)

  # replace name version and date
  replace_header(spec, :name)
  replace_header(spec, :version)
  replace_header(spec, :date)
  #comment this out if your rubyforge_project has a different name
  #TODO: Need to figure out how this works... replace_header(spec, :rubyforge_project)

  File.open(gemspec_file, 'w') { |io| io.write(spec) }
  puts "Updated #{gemspec_file}"
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
  files.shuffle.each do |test|
    prerequisite = "pre #{test}"
    task prerequisite do
      puts "==== #{test} ===="
    end
    rspectest = "rspec #{test}"
    task = RSpec::Core::RakeTask.new(rspectest) do |t|
      t.pattern = test
      t.fail_on_error = false
      t.rspec_opts = %Q{--color --require "#{File.dirname(__FILE__)}/jenkins/triple_formatter.rb"}
    end
    if test != "spec/integration/commands/servers/add_spec.rb"
      if test.include?("spec/integration/commands/addresses") ||
         test.include?("spec/integration/commands/servers/metadata") ||
         test.include?("spec/integration/commands/images/metadata") ||
         test.include?("spec/integration/commands/securitygroups")
        task test => [ prerequisite, rspectest ] do
          sleep 40
        end
      else
        task test => [ prerequisite, rspectest ]
      end
    end
  end

  task :spec => files


end

desc "Setup package for release"
namespace :release do

  desc "build a release version of the gem"
  task :build => :preflight do
    puts "Running release build"
    Rake::Task[:build].invoke
    sh "gem install pkg/#{name}-#{version}.gem"
    puts "installed gem #{name}-#{version}"
    Rake::Task[:git_mark_release].invoke
  end

  desc "preflight the build and check for existing tags"
  task :preflight do
    puts "checking preflight"
    # unless `git branch` =~ /^\* master$/
    #   puts "You must be on the master branch to release!"
    #   exit!
    # end
    # if `git tag` =~ /^\* v#{version}$/
    #   puts "Tag v#{version} already exists!"
    #   exit!
    # end
  end
end

task :git_mark_release do
  sh "git commit --allow-empty -a -m 'Release #{version}'"
  sh "git tag v#{version}"
end

# Create gem file
desc "Build hpcloud-#{version}.gem"
task :build => :gemspec do
  sh "mkdir pkg" if ! Dir.exist?(File.join(File.dirname(__FILE__ ), 'pkg'))
  sh "gem build #{gemspec_file}"
  sh "mv #{gem_file} pkg"
end
task :gem => :build

require 'yard'
YARD::Rake::YardocTask.new
