module KidsCloset

  class CalculateSaleFinancials < Struct.new(:sale_id)

    def perform
      Site.current_site_id = 1
      sale = Sale.find(sale_id)
      sale.calculate_financials
    end
  end
end