source "http://rubygems.org"

gemspec
#gem 'hpfog', :path => '~/projects/ruby_fog_os'
gem 'hpfog', :git => 'git@git.hpcloud.net:SDK-CLI-Docs/ruby_fog_os.git', :branch => 'master'

group :development do
  gem "yard", "~> 0.6.0"
  gem "watchr"
end

group :test do
  gem 'simplecov', '>= 0.4.0', :require => false
end

group :ci do
  gem 'ci_reporter', "~> 1.6.4"
end
