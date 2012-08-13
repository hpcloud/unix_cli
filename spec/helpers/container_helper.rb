class ContainerHelper
  def self.list(container)
    container = Connection.instance.storage.get_container(container)
    ray = []
    container.body.each { |file|
      ray << file['name']
    } 
    ray.sort!
    return (ray * ",")
  end
end
