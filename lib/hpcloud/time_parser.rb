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

module HP
  module Cloud

    class TimeParser
      def self.parse(str)
          return nil if str.nil?
          ray = str.scan(/(\d+)(\w)/)
          if ray.nil? || ray[0].nil?
            raise Exception.new("The expected time format contains value and unit like 2d for two days.  Supported units are s, m, h, or d")
          end
          case ray[0][1]
          when "s"
            return ray[0][0].to_i
          when "m"
            return ray[0][0].to_i * 60
          when "h"
            return ray[0][0].to_i * 60 * 60
          when "d"
            return ray[0][0].to_i * 60 * 60 * 24
          else
            raise Exception.new("Unrecognized time unit #{ray[0][1]} in #{str} expected s, m, h, or d")
          end
      end
    end
  end
end
