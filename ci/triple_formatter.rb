# this file is only expected to be used from inside jenkins rake tasks and will fail in other contexts
# AKA, it is a dirty hack to get us three kinds of output at once
# 1. progress dots (for monitoring during running) -- from ci_formatter
# 2. HTML report (for Jenkins pubishing) -- from html_formatter
# 3. JUnit output (for Jenkins graphs) -- from ci_formatter
#
# there's a decent chance this will break one of these days...
#
require 'rspec/core/formatters/html_formatter'
require 'ci/reporter/rspec'

config = RSpec.configuration
#config.color_enabled = true
html_formatter = RSpec::Core::Formatters::HtmlFormatter.new(File.open("ci/reports/html/index.html", "w"))
ci_formatter = CI::Reporter::RSpec.new(config.output)
config.instance_variable_set(:@reporter, RSpec::Core::Reporter.new(html_formatter, ci_formatter))