module KidsCloset

  class MoveFeaturedFile < Struct.new(:item_id)

    def perform
      Site.current_site_id = 1
      FeaturedPhoto.rename_featured_file(item_id)
    end

  end

end