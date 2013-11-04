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


RSpec.configure do |config|
  
  # Delete a single container, regardless of files present
  def purge_container(container_name, options={})
    connection = options[:connection] || @hp_svc
    verbose = options[:verbose] || false
    begin
      puts "Deleting '#{container_name}'" if verbose
      connection.delete_container(container_name) unless connection.nil?
    rescue Fog::Storage::HP::NotFound # container is listed, but does not currently exist
    rescue Excon::Errors::Conflict # container has files in it
      begin
        tainer = connection.directories.get(container_name)
        unless tainer.nil?
          tainer.files.each do |file|
            begin
              puts "  - removing file '#{file.key}'" if verbose
              file.destroy
            end
          end
          connection.delete_container(container_name)
        end
      end
    end
  end

  def create_container_with_files(container_name, *files)
    #container_name = container_name(container_seed)
    @hp_svc.put_container(container_name)
    files.each do |file_name|
      @hp_svc.put_object(container_name, file_name, read_file(file_name))
    end
    container_name
  end
  
end
