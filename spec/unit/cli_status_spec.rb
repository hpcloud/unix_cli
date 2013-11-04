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

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "CliStatus" do
  context "construct nothing" do
    it "gets success" do
      status = HP::Cloud::CliStatus.new

      status.get.should eq(0)
      status.to_s.should eq('')
    end
  end

  context "construct with values" do
    it "gets error" do
      status = HP::Cloud::CliStatus.new("shoot", :general_error)

      status.get.should eq(1)
      status.to_s.should eq('shoot')
    end
  end

  context "construct nothing and set" do
    it "gets error" do
      status = HP::Cloud::CliStatus.new

      status.set(:conflicted)

      status.get.should eq(5)
    end
  end

  context "construct priority set" do
    it "gets error" do
      status = HP::Cloud::CliStatus.new
      status.set(:permission_denied)

      status.set(:conflicted)

      status.get.should eq(77)
    end
  end

  context "construct bogus set" do
    it "gets error" do
      status = HP::Cloud::CliStatus.new

      status.set(:bogus)

      status.get.should eq(99)
    end
  end

  context "construct string set" do
    it "gets error" do
      status = HP::Cloud::CliStatus.new

      status.set('bogus')

      status.get.should eq(99)
    end
  end
end
