require File.dirname(__FILE__) + '/../test_helper'

class SaleSeasonTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  
  fixtures :sale_seasons, :consignor_inventories, :sales
  
  test "check fixtures got loaded" do
    assert_equal 3, SaleSeason.count
  end
  
  test "sale season must have start date" do
    sale_season = SaleSeason.new
    sale_season.season_name = "Fall"
    sale_season.end_date = Date.today + 540
    assert !sale_season.save, "Saved Sale Season without the Start Date"
    sale_season.start_date = Date.today + 366
    assert sale_season.save, "adding start date did NOT save the season"
    
  end
  
  test "sale season must have end date" do
    sale_season = SaleSeason.new
    sale_season.season_name = "Fall"
    sale_season.start_date = Date.today + 366
    assert !sale_season.save, "Saved Sale Season without the End Date"
    sale_season.end_date = Date.today + 540
    assert sale_season.save, "adding end date did NOT save the season"
  end

  test "sale season must have a name" do
    sale_season = SaleSeason.new
    sale_season.start_date = Date.today
    sale_season.end_date = Date.today + 180
    assert !sale_season.save, "Saved Sale Season without the Season Name"
    sale_season.season_name = "Fall"
    assert sale_season.save, "adding season name did NOT save the season"
  end
  
  test "sale season must have a start date before the end date" do
    sale_season = SaleSeason.new
    sale_season.season_name = "Fall"
    sale_season.start_date = Date.today + 366
    sale_season.end_date = Date.today - 1
    assert !sale_season.save, "Saved Sale Season with dates out of order"
    sale_season.end_date = Date.today + 540
    assert sale_season.save, "fixing end date did NOT save the season"
  end
    
  test "sale season does not save duplicate season name" do
    sale_season = SaleSeason.new
    sale_season.season_name = "Spring 2010"
    sale_season.start_date = Date.today + 366
    sale_season.end_date = Date.today + 540
    assert !sale_season.save, "Season saved with the same name as the default season"
    sale_season.season_name = "Spring 2011"
    assert sale_season.save, "fixing season name did NOT save the season"
  end

  test "sale season saves with good information" do
    sale_season = SaleSeason.new
    sale_season.season_name = "Fall"
    sale_season.start_date = Date.today + 361
    sale_season.end_date = Date.today + 540
    assert sale_season.save, "A valid sale season did not save"
  end
  
  test "reading of season dates" do
    assert_equal sale_seasons(:spring).season_dates, "January 01, 2010 - June 30, 2010"
  end

  test "the current sale season should be the Current one" do
    assert_equal SaleSeason.current_sale_season, sale_seasons(:current)
  end
  
  test "the future season should be 'latest sale season'" do
    sale_season = SaleSeason.new
    sale_season.season_name = "Fall"
    sale_season.start_date = sale_seasons(:spring).start_date - 365
    sale_season.end_date = sale_seasons(:spring).end_date - 365
    sale_season.save
    assert_equal(SaleSeason.latest_sale_season, sale_seasons(:future), "The latest sale season in the database is not the spring season")
  end

  test "a season starting next year should be the latest sale season" do
    sale_season = SaleSeason.new
    sale_season.season_name = "Fall"
    sale_season.start_date = Date.today + 365
    sale_season.end_date = Date.today + 545
    sale_season.save
    assert_equal(SaleSeason.latest_sale_season, sale_season, "The latest sale season in the database is not the one just added")
  end

  test "spring sale season has 450 items sold" do
    sale_season = sale_seasons(:spring)
    assert_equal(sale_season.items_sold.count, 450, "spring sale season did not have 450 sold items")
  end
  
  test "current sale season has 0 items sold" do
    sale_season = sale_seasons(:current)
    assert_equal(sale_season.items_sold.count, 0, "spring sale season did not have 0 sold items")
  end
  
  test "future sale season has 0 items sold" do
    sale_season = sale_seasons(:future)
    assert_equal(sale_season.items_sold.count, 0, "spring sale season did not have 0 sold items")
  end

  test "selling some items in current sale season increases items sold count" do
    for i in 1..75
      item = ConsignorInventory.find(i + 450)
      item.sale_id = sales(:florida_current).id
      item.sale_price = 1
      item.status = true
      item.tax_collected = 0.08
      item.total_price = 1.08
      item.sale_date = Date.today + 61
      item.transaction_number = 4
      item.discounted_at_sale = false
      item.transaction_import_id = 3
      item.rewards_profile_id = rewards_profiles(:rewards_profile_1).id
      item.save
    end
    sale_season = sale_seasons(:current)
    assert_equal(sale_season.items_sold.count, 75, "spring sale season did not have 75 sold items")
  end

  test "clearing sold items in spring gets rid of all items sold" do
    sale_season = sale_seasons(:spring)
    sale_season.clear_sold_items
    assert_equal(sale_season.items_sold.count, 0, "spring sale season did not have 0 sold items after clear out")
  end
  
  test "clearing sold items in spring gets rid of all items sold but keeps unsold items in database" do
    sale_season = sale_seasons(:spring)
    sale_season.clear_sold_items
    assert_equal(ConsignorInventory.count, 300, "do not have 300 items left over after clearing sold items")
  end

  test "selling some items in current sale season increases, deleting items sold in current season keeps 75 sold items" do
    for i in 1..75
      item = ConsignorInventory.find(i + 450)
      item.sale_id = sales(:florida_current).id
      item.sale_price = 1
      item.status = true
      item.tax_collected = 0.08
      item.total_price = 1.08
      item.sale_date = Date.today + 61
      item.transaction_number = 4
      item.discounted_at_sale = false
      item.transaction_import_id = 3
      item.rewards_profile_id = rewards_profiles(:rewards_profile_1).id
      item.save
    end
    sale_season = sale_seasons(:spring)
    sale_season.clear_sold_items
    sale_season = sale_seasons(:current)
    assert_equal(sale_season.items_sold.count, 75, "currnet sale season did not have 75 sold items")
  end

  test "can not clear items for a current sale season" do
    for i in 1..75
      item = ConsignorInventory.find(i + 450)
      item.sale_id = sales(:florida_current).id
      item.sale_price = 1
      item.status = true
      item.tax_collected = 0.08
      item.total_price = 1.08
      item.sale_date = Date.today + 61
      item.transaction_number = 4
      item.discounted_at_sale = false
      item.transaction_import_id = 3
      item.rewards_profile_id = rewards_profiles(:rewards_profile_1).id
      item.save
    end
    sale_season = sale_seasons(:current)
    sale_season.clear_sold_items
    sale_season = sale_seasons(:current)
    assert_equal(sale_season.items_sold.count, 75, "current sale season did not have 75 sold items")
  end
  
  test "last sale date for spring is april 2, 2010" do
    sale_season = sale_seasons(:spring)
    assert_equal(sale_season.last_sale_date.strftime("%b %d, %Y"), "Apr 02, 2010", "last sale date for spring was not April 2, 2010")
  end
  
  test "unsold items for spring should total 100" do
    sale_season = sale_seasons(:spring)
    assert_equal(sale_season.unsold_items_for_season.count, 100, "spring season does not have 100 unsold items")
  end
  
  test "update items not coming to sale clears out bring to sale count" do
    sale_season = sale_seasons(:spring)
    sale_season.clear_sold_items
    sale_season.update_items_not_coming_to_sale
    sale = Sale.find(sales(:kansas_spring).id)
    assert_equal(sale.number_of_possible_sale_items, 100, "Number of sale items coming to Kansas was not 100")    
  end
end
