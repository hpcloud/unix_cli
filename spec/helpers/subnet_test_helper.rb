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


class SubnetTestHelper
  @@subnet_cache = {}

  def self.create(name)
    return @@subnet_cache[name] unless @@subnet_cache[name].nil?
    subnets = HP::Cloud::Subnets.new
    subnet = subnets.get(name)
    if subnet.is_valid?
      @@subnet_cache[name] = subnet
      return subnet
    end
    network1 = NetworkTestHelper.create("cli_test_network1")
    subnet = HP::Cloud::SubnetHelper.new(Connection.instance)
    subnet.name = name
    subnet.network_id = network1.id
    subnet.set_cidr(name + "/24")
    subnet.set_gateway("127.0.0.1")
    subnet.dhcp = true
    subnet.save
    @@subnet_cache[name] = subnet
    return subnet
  end
end
