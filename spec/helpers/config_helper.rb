# encoding: utf-8
#
# © Copyright 2013 Hewlett-Packard Development Company, L.P.
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

class ConfigHelper
  @@tmpdir = nil

  def self.use_fixtures()
    home = File.expand_path(File.dirname(__FILE__) + "/../fixtures/config")
    HP::Cloud::Config.home_directory = home
  end

  def self.tmp_directory()
    @@tmpdir = File.expand_path(File.dirname(__FILE__) + "/../tmp/home")
  end

  def self.use_tmp()
    @@tmpdir = ConfigHelper.tmp_directory()
    FileUtils.rm_rf(@@tmpdir)
    FileUtils.mkpath(@@tmpdir)
    HP::Cloud::Config.home_directory = @@tmpdir
  end

  def self.reset()
    FileUtils.rm_rf(@@tmpdir) unless @@tmpdir.nil?
    HP::Cloud::Config.home_directory = nil
    @@tmpdir = nil
  end

  def self.contents()
    file_name = ConfigHelper.tmp_directory() + "/.hpcloud/config.yml"
    return File.read(file_name)
  end

  def self.value(key)
    file_name = ConfigHelper.tmp_directory() + "/.hpcloud/config.yml"
    yaml = YAML::load(File.open(file_name))
    return yaml[key]
  end
end
