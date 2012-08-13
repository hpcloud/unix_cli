class DirectoryHelper
  def self.list(directory)
    actual = Dir.entries(directory).sort
    actual.delete_if {|x| x == "." || x == ".." }
    return (actual * ",")
  end
end
