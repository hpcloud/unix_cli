module HP
  module Cloud
    class CLI < Thor

      map %w(images:rm images:delete images:del) => 'images:remove'

      desc "images:remove name_or_id [name_or_id ...]", "Remove images by name or identifier."
      long_desc <<-DESC
  Remove existing images by specifying thier names or IDs. Optionally, you may specify an availability zone.

Examples:
  hpcloud images:remove my-image                           # Delete image 'my-image':
  hpcloud images:remove 1172 1078                          # Delete images '1172' and '1078':
  hpcloud images:remove my-image -z az-2.region-a.geo-1    # Delete image `my-image` for availability zone `az-2.region-a.geo-1:

Aliases: images:rm, images:delete, images:del
      DESC
      CLI.add_common_options
      define_method "images:remove" do |name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          images = Images.new.get(name_or_ids, false)
          images.each { |image|
            sub_command("removing image") {
              if image.is_valid?
                image.fog.destroy
                @log.display "Removed image '#{image.name}'."
              else
                @log.error image.cstatus
              end
            }
          }
        }
      end

    end
  end
end
