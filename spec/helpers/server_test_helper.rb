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


class ServerTestHelper
  @@server_cache = {}

  def self.create(name)
    return @@server_cache[name] unless @@server_cache[name].nil?
    keypair = KeypairTestHelper.create("cli_test_key1")
    servers = HP::Cloud::Servers.new
    server = servers.get(name)
    if server.is_valid?
      @@server_cache[name] = server
      return server
    end
    server = servers.create()
    server.name = name
    server.flavor = AccountsHelper.get_flavor_id().to_i
    server.image = AccountsHelper.get_image_id()
    server.set_keypair(keypair.name)
    server.set_network('cli_test_network1')
    server.save
    server.fog.wait_for { ready? }
    @@server_cache[name] = server
    return server
  end
end
