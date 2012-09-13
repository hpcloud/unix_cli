
class ImageTestHelper
  @@image_cache = {}

  def self.create(name, srv)
    return @@image_cache[name] unless @@image_cache[name].nil?
    images = HP::Cloud::Images.new
    image = images.get(name)
    if image.is_valid?
      @@image_cache[name] = image
      return image
    end
    image = images.create()
    image.name = name
    image.set_server("#{srv.name}")
    image.meta.set_metadata('darth=vader,count=dooku')
    image.save
    @@image_cache[name] = image
    return image
  end
end
