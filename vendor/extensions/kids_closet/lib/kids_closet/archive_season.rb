module KidsCloset

  class ArchiveSeason < Struct.new(:sale_season_id)

    def perform
      Site.current_site_id = 1
      sale_season = SaleSeason.find(sale_season_id)
      sale_season.clear_sold_items
      sale_season.update_items_not_coming_to_sale
    end
  end
end