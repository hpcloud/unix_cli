
RSpec.configure do |config|
  
  # read file contents of a file in fixtures/files/<filename>
  def read_file(filename)
    read_fixture(:file, filename)
  end

  # read file contents of a file in fixtures/accounts/<filename>
  def read_account_file(filename)
    read_fixture(:account, filename)
  end

  def read_fixture(type, filename)
    dir_name = type.to_s + "s" # simple pluralize
    File.read(File.dirname(__FILE__) + "/../fixtures/#{dir_name}/#{filename}")
  end
  
end

