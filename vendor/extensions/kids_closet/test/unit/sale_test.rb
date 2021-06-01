require File.dirname(__FILE__) + '/../test_helper'

class SaleTest < ActiveSupport::TestCase
  # Replace this with your real tests.

  fixtures :franchises, :sales, :sale_seasons, :sale_volunteer_times, :consignor_inventories
  
  test "check fixtures got loaded" do
    assert_equal 4, Sale.count
  end

  test "sale belongs to a valid sale season" do
    sale = Sale.new
    sale.franchise = franchises(:kansas)
    sale.start_date = Date.today + 1000
    sale.end_date = Date.today + 1001
    sale.sale_address = "Nowhere"
    sale.sale_zip_code = 66213
    sale.sale_percentage = 70
    sale.sale_advert_cost = 12.50
    sale.active = 0
    sale.facility_name = "My Place"
    sale.sale_hours_1 = "TBA"
    assert !sale.save, "sale saved with invalid sale season"
    sale.start_date = Date.today + 200
    sale.end_date = Date.today + 201
    assert sale.save, "fixing sale dates did NOT save the sale"
  end

  test "sale must have an end date after the start date" do
    sale = Sale.new
    sale.franchise = franchises(:kansas)
    sale.start_date = Date.today + 300
    sale.end_date = Date.today + 298
    sale.sale_address = "Nowhere"
    sale.sale_zip_code = 66213
    sale.sale_percentage = 70
    sale.sale_advert_cost = 12.50
    sale.active = 0
    sale.facility_name = "My Place"
    sale.sale_hours_1 = "TBA"
    assert !sale.save, "sale saved with invalid dates"
    sale.end_date = Date.today + 302
    assert sale.save, "fixing the end dates did NOT save the sale"
  end

  test "only one sale allowed per sale season for franchise" do
    sale = Sale.new
    sale.franchise = franchises(:kansas)
    sale.start_date = Date.today + 100
    sale.end_date = Date.today + 103
    sale.sale_address = "Nowhere"
    sale.sale_zip_code = 66213
    sale.sale_percentage = 70
    sale.sale_advert_cost = 12.50
    sale.active = 0
    sale.facility_name = "My Place"
    sale.sale_hours_1 = "TBA"
    assert !sale.save, "sale saved with invalid sale season"
    sale.start_date = Date.today + 300
    sale.end_date = Date.today + 302
    assert sale.save, "fixing the sale dates did NOT save the sale"
  end

  test "sale must have a facility name" do
    sale = Sale.new
    sale.franchise = franchises(:kansas)
    sale.start_date = Date.today + 310
    sale.end_date = Date.today + 311
    sale.sale_address = "Nowhere"
    sale.sale_zip_code = 66213
    sale.sale_percentage = 70
    sale.sale_advert_cost = 12.50
    sale.active = 0
    sale.sale_hours_1 = "TBA"
    assert !sale.save, "sale saved with no facility name"
    sale.facility_name = "TBA"
    assert sale.save, "adding facility name did NOT save the sale"    
  end

  test "sale must have sale hours" do
    sale = Sale.new
    sale.franchise = franchises(:kansas)
    sale.start_date = Date.today + 310
    sale.end_date = Date.today + 311
    sale.sale_address = "Nowhere"
    sale.sale_zip_code = 66213
    sale.sale_percentage = 70
    sale.sale_advert_cost = 12.50
    sale.active = 0
    sale.facility_name = "My Place"
    assert !sale.save, "sale saved with no sale hours"
    sale.sale_hours_1 = "TBA"
    assert sale.save, "adding the sale hours did NOT save the sale"
  end

  test "facility name must not be over 45 characters" do
    sale = Sale.new
    sale.franchise = franchises(:kansas)
    sale.start_date = Date.today + 310
    sale.end_date = Date.today + 311
    sale.sale_address = "Nowhere"
    sale.sale_zip_code = 66213
    sale.sale_percentage = 70
    sale.sale_advert_cost = 12.50
    sale.active = 0
    sale.facility_name = "This line of information will have over 45 characters, which violates the limit"
    sale.sale_hours_1 = "TBA"
    assert !sale.save, "sale saved with facility name over 45 characters"
    sale.facility_name = "TBA"
    assert sale.save, "fixing facility name did NOT save the sale"    
  end

  test "sale percentage must be a number" do
    sale = Sale.new
    sale.franchise = franchises(:kansas)
    sale.start_date = Date.today + 310
    sale.end_date = Date.today + 311
    sale.sale_address = "Nowhere"
    sale.sale_zip_code = 66213
    sale.sale_percentage = "ab123"
    sale.sale_advert_cost = 12.50
    sale.active = 0
    sale.facility_name = "TBA"
    sale.sale_hours_1 = "TBA"
    assert !sale.save, "sale saved with invalid sale percentage"
    sale.sale_percentage = 70
    assert sale.save, "fixing sale percentage did NOT save the sale"
  end

  test "sale percentage must be greater than 0" do
    sale = Sale.new
    sale.franchise = franchises(:kansas)
    sale.start_date = Date.today + 310
    sale.end_date = Date.today + 311
    sale.sale_address = "Nowhere"
    sale.sale_zip_code = 66213
    sale.sale_percentage = -1
    sale.sale_advert_cost = 12.50
    sale.active = 0
    sale.facility_name = "TBA"
    sale.sale_hours_1 = "TBA"
    assert !sale.save, "sale saved with sale percentage less than 0"
    sale.sale_percentage = 70
    assert sale.save, "fixing sale percentage did NOT save the sale"
  end

  test "sale percentage must be less than 100" do
    sale = Sale.new
    sale.franchise = franchises(:kansas)
    sale.start_date = Date.today + 310
    sale.end_date = Date.today + 311
    sale.sale_address = "Nowhere"
    sale.sale_zip_code = 66213
    sale.sale_percentage = 110
    sale.sale_advert_cost = 12.50
    sale.active = 0
    sale.facility_name = "TBA"
    sale.sale_hours_1 = "TBA"
    assert !sale.save, "sale saved sale percentage greater than 0"
    sale.sale_percentage = 70
    assert sale.save, "fixing sale percentage did NOT save the sale"
  end

  test "sale percentage must be 65 or +70" do
    sale = Sale.new
    sale.franchise = franchises(:kansas)
    sale.start_date = Date.today + 310
    sale.end_date = Date.today + 311
    sale.sale_address = "Nowhere"
    sale.sale_zip_code = 66213
    sale.sale_percentage = 34
    sale.sale_advert_cost = 12.50
    sale.active = 0
    sale.facility_name = "TBA"
    sale.sale_hours_1 = "TBA"
    assert !sale.save, "sale saved sale percentage other than 65 or 70"
    sale.sale_percentage = 70
    assert sale.save, "fixing sale percentage did NOT save the sale"
  end

  test "sale percentage must be +65 or 70" do
    sale = Sale.new
    sale.franchise = franchises(:kansas)
    sale.start_date = Date.today + 310
    sale.end_date = Date.today + 311
    sale.sale_address = "Nowhere"
    sale.sale_zip_code = 66213
    sale.sale_percentage = 34
    sale.sale_advert_cost = 12.50
    sale.active = 0
    sale.facility_name = "TBA"
    sale.sale_hours_1 = "TBA"
    assert !sale.save, "sale saved sale percentage other than 65 or 70"
    sale.sale_percentage = 65
    assert sale.save, "fixing sale percentage did NOT save the sale"
  end

  test "sale percentage of 70 returns right file name for flyer" do
    sale = Sale.new
    sale.franchise = franchises(:kansas)
    sale.start_date = Date.today + 310
    sale.end_date = Date.today + 311
    sale.sale_address = "Nowhere"
    sale.sale_zip_code = 66213
    sale.sale_advert_cost = 12.50
    sale.active = 0
    sale.facility_name = "TBA"
    sale.sale_hours_1 = "TBA"
    sale.sale_percentage = 70
    sale.save
    assert_equal sale.flyer_footer_image, 'flyer_bottom_70.jpg'
  end

  test "sale percentage of 65 returns right file name for flyer" do
    sale = Sale.new
    sale.franchise = franchises(:kansas)
    sale.start_date = Date.today + 310
    sale.end_date = Date.today + 311
    sale.sale_address = "Nowhere"
    sale.sale_zip_code = 66213
    sale.sale_advert_cost = 12.50
    sale.active = 0
    sale.facility_name = "TBA"
    sale.sale_hours_1 = "TBA"
    sale.sale_percentage = 65
    sale.save
    assert_equal sale.flyer_footer_image, 'flyer_bottom_65.jpg'
  end

  test "sale advertisement fee must be greater than 0" do
    sale = Sale.new
    sale.franchise = franchises(:kansas)
    sale.start_date = Date.today + 310
    sale.end_date = Date.today + 311
    sale.sale_address = "Nowhere"
    sale.sale_zip_code = 66213
    sale.sale_percentage = 70
    sale.sale_advert_cost = -12.50
    sale.active = 0
    sale.facility_name = "TBA"
    sale.sale_hours_1 = "TBA"
    assert !sale.save, "sale saved with sale advertisement less than 0"
    sale.sale_advert_cost = 12.50
    assert sale.save, "fixing sale advert cost did NOT save the sale"
  end

  test "sale advertisement fee must be less than 15" do
    sale = Sale.new
    sale.franchise = franchises(:kansas)
    sale.start_date = Date.today + 310
    sale.end_date = Date.today + 311
    sale.sale_address = "Nowhere"
    sale.sale_zip_code = 66213
    sale.sale_percentage = 70
    sale.sale_advert_cost = 20
    sale.active = 0
    sale.facility_name = "TBA"
    sale.sale_hours_1 = "TBA"
    assert !sale.save, "sale saved with sale advertisement greater than 15"
    sale.sale_advert_cost = 12.50
    assert sale.save, "fixing sale advert cost did NOT save the sale"
  end

  test "sale advertisement fee must be a valid number" do
    sale = Sale.new
    sale.franchise = franchises(:kansas)
    sale.start_date = Date.today + 310
    sale.end_date = Date.today + 311
    sale.sale_address = "Nowhere"
    sale.sale_zip_code = 66213
    sale.sale_percentage = 70
    sale.sale_advert_cost = "zyx388"
    sale.active = 0
    sale.facility_name = "TBA"
    sale.sale_hours_1 = "TBA"
    assert !sale.save, "sale saved with invalid sale advertisement"
    sale.sale_advert_cost = 12.50
    assert sale.save, "fixing sale advert cost did NOT save the sale"
  end
  
  test "valid sale should save" do
    sale = Sale.new
    sale.franchise = franchises(:kansas)
    sale.start_date = Date.today + 310
    sale.end_date = Date.today + 311
    sale.sale_address = "Nowhere"
    sale.sale_zip_code = 66213
    sale.sale_percentage = 70
    sale.sale_advert_cost = 12.50
    sale.active = 0
    sale.facility_name = "TBA"
    sale.sale_hours_1 = "TBA"
    assert sale.save, "a valid sale did not save"
    assert_not_nil(SaleConsignorTime.internal_time_for_sale(sale.id), "Internal Sign Up Time not created")
    assert_equal(sale.sale_season, sale_seasons(:future), "Sale did not get assigned to the correct sale season")
  end  
  
  test "new active sale should be one and only active sale" do
    sale = Sale.new
    sale.franchise = franchises(:kansas)
    sale.start_date = Date.today + 310
    sale.end_date = Date.today + 311
    sale.sale_address = "Nowhere"
    sale.sale_zip_code = 66213
    sale.sale_percentage = 70
    sale.sale_advert_cost = 12.50
    sale.active = 1
    sale.facility_name = "TBA"
    sale.sale_hours_1 = "TBA"
    assert sale.save, "a valid sale did not save"
    assert_not_nil(SaleConsignorTime.internal_time_for_sale(sale.id), "Internal Sign Up Time not created")
    assert_equal(sale.sale_season, sale_seasons(:future), "Sale did not get assigned to the correct sale season")
    franchise = franchises(:kansas)
    assert_equal 5, Sale.count
    assert_equal(franchise.active_sale, sale, "Sale is not the active sale for kansas")
    assert_equal(franchise.sales.count, 3, "Kansas does not have 3 sales")
    assert_equal(franchise.sales.count(:id, :conditions => ["active = ?", true]), 1, "Kansas does not have 1 active sale")
    assert !sales(:kansas_spring).active, "kansas spring sale was marked as active"
    assert !sales(:kansas_current).active, "kansas current sale was marked as active"
  end  

  test "verify sale and pdf dates" do
    assert_equal(sales(:kansas_spring).sale_dates, "March 01, 2010 - March 03, 2010", "kansas spring sale dates not correct")
    assert_equal(sales(:kansas_spring).pdf_dates, "March 01 - 03, 2010", "kansas spring pdf dates not correct")
    assert_equal(sales(:florida_spring).sale_dates, "Spring 2010", "florida spring sale dates not correct")
    assert_equal(sales(:florida_spring).pdf_dates, "Spring 2010", "florida spring pdf dates not correct")
  end
  
  test "verify sale title" do
    assert_equal(sales(:kansas_spring).sale_title, "Overland Park, KS", "sale title not reported correctly")
  end

  test "verify sale and pdf addresses" do
    sale = Sale.find(sales(:kansas_spring).id)
    assert_equal(sale.formatted_address, %{
      <div id="formatted_address_1" class="formatted_address">
        Cartagena Home<br>
        8903 W 132nd Pl<br>
        Overland Park, Kansas 66213
      </div>
    }, "kansas spring formatted address not correct")
    assert_equal(sale.pdf_address, %{
        Behind HyVee<br>
        8903 W 132nd Pl<br>
        Overland Park, Kansas 66213
    }, "kansas spring pdf address not correct")
    sale = Sale.find(sales(:kansas_current).id)
    assert_equal(sale.pdf_address, %{
        Behind HyVee at the corner of antioch <br>
        8903 W 132nd Pl<br>
        Overland Park, Kansas 66213
    }, "kansas current pdf address not correct")
    sale = Sale.find(sales(:florida_spring).id)
    assert_equal(sale.formatted_address, %{
      <div id="formatted_address_3" class="formatted_address">
        Cartagena Home<br>
        575 Laurel Oaks Ct NE<br>
        Palm Bay, Florida 32907
      </div>
    }, "florida spring formatted address not correct")
    assert_equal(sale.pdf_address, %{
        
        575 Laurel Oaks Ct NE<br>
        Palm Bay, Florida 32907
    }, "florida spring pdf address not correct")
  end

  test "verify latest sales from test data" do
    assert_equal(Sale.latest_sale_for_franchise(franchises(:florida).id), sales(:florida_current), "Current Florida Sale not the latest one")
    assert_equal(Sale.latest_sale_for_franchise(franchises(:kansas).id), sales(:kansas_current), "Current Kansas Sale not the latest one")
    assert_equal(Sale.current_active_sale(franchises(:florida).id), sales(:florida_current), "Current Florida Sale not the latest active one")
    assert_equal(Sale.current_active_sale(franchises(:kansas).id), sales(:kansas_current), "Current Kansas Sale not the latest active one")
    assert_equal(Sale.current_active_sale_id(franchises(:florida).id), sales(:florida_current).id, "Current Florida Sale ID not the latest active one")
    assert_equal(Sale.current_active_sale_id(franchises(:kansas).id), sales(:kansas_current).id, "Current Kansas Sale ID not the latest active one")
  end

  test "consignor sort options" do
    assert_equal(Sale.consignor_sort_options, [["Consignor #", "id"], ["Name", ""], ["Email Address", "email"]], "consignor sort options not matched")
  end  

  test "items sold for florida should be 340" do
    sale = Sale.find(sales(:florida_spring).id)
    assert_equal(sale.calculate_number_of_items_sold, 340, "Items sold for Florida was not 340")
  end
  
  test "items sold for florida should be 340 after financials are calculated" do
    calculate_all_financials
    sale = Sale.find(sales(:florida_spring).id)
    assert_equal(sale.total_items_sold, 340, "Items sold for Florida was not 340")
  end

  test "total sold for florida should be 340" do
    sale = Sale.find(sales(:florida_spring).id)
    assert_equal(sale.calculate_total_sold, 340, "Items sold for Florida was not 340")
  end
  
  test "total sold for florida should be 340 after financials are calculated" do
    calculate_all_financials
    sale = Sale.find(sales(:florida_spring).id)
    assert_equal(sale.total_amount_sold, 340, "Items sold for Florida was not 340")
  end
  
  test "tax collected for florida should be 27.2" do
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    assert_equal(sale.tax_received, 27.2, "Items sold for Florida was not 340")
  end

  test "total collected for florida should be 367.2" do
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    assert_equal(sale.calculate_total_collected, 367.2, "Items sold for Florida was not 340")
  end  

  test "percent fees collected for florida should be 92" do
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    assert_equal(sale.calculate_percent_fees_collected, 102, "Percent Fees for Florida did not add up")
  end

  test "advertisement fees collected for florida should be percent 18" do
    calculate_all_financials
    sale = Sale.find(sales(:florida_spring).id)
    assert_equal(sale.calculate_advertisement_fees_collected, 18, "Advertisement Fees for Florida did not add up")
  end

  test "check number of consignors for Florida" do
    sale = Sale.find(sales(:florida_spring).id)
    assert_equal(sale.number_of_consignors, 3, "Number of Consignors for Florida was not 3")    
  end

  test "check number of consignors with sold items for Florida" do
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    assert_equal(sale.calculate_consignors_that_sold_items, 3, "Number of Consignors with sold items for Florida was not 3")    
  end

  test "check number of transactions for Florida" do
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    assert_equal(sale.transaction_count, 3, "Number of Transactions for Florida was not 3")    
  end
    
  test "check extra income for Florida" do    
    sale = Sale.find(sales(:florida_spring).id)
    assert_equal(sale.extra_income, 100, "Extra Income for Florida was not 100")    
  end

  test "check gross revenue for Florida" do    
    calculate_all_financials
    sale = Sale.find(sales(:florida_spring).id)
    assert_equal(sale.calculate_gross_revenue, 458, "Gross Revenue for Florida was not 458")    
  end

  test "check total revenue for Florida" do    
    calculate_all_financials
    sale = Sale.find(sales(:florida_spring).id)
    assert_equal(sale.calculate_total_revenue, 467.2, "Total Revenue for Florida was not 467.2")    
  end

  test "check gross profit for Florida" do    
    calculate_all_financials
    sale = Sale.find(sales(:florida_spring).id)
    assert_equal(sale.calculate_gross_profit, 220, "Gross Profit for Florida was not 210")    
  end

  test "check royalty fee for Florida" do    
    calculate_all_financials
    sale = Sale.find(sales(:florida_spring).id)
    assert_equal(sale.calculate_royalty_fee, 13.74, "Royalty Fee for Florida was not 13.74")    
  end

  test "check net profit for Florida" do
    calculate_all_financials
    sale = Sale.find(sales(:florida_spring).id)
    assert_equal(sale.calculate_net_profit, 206.26, "Net Profit for Florida was not 206.26")    
  end
    
  test "items coming to Florida should be 200" do
    sale = Sale.find(sales(:florida_spring).id)
    assert_equal(sale.number_of_possible_sale_items, 200, "Number of sale items coming to Florida was not 200")    
  end
  
  test "items coming to Florida should be 200 even after items are sold" do
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    assert_equal(sale.number_of_possible_sale_items, 200, "Number of sale items coming to Kansas was not 200")    
  end
  
  test "items sold for kansas should be 110" do
    sale = Sale.find(sales(:kansas_spring).id)
    assert_equal(sale.calculate_number_of_items_sold, 110, "Items sold for kansas was not 340")
  end
  
  test "items sold for kansas should be 110 after financials are calculated" do
    calculate_all_financials
    sale = Sale.find(sales(:kansas_spring).id)
    assert_equal(sale.total_items_sold, 110, "Items sold for kansas was not 340")
  end
  
  test "total sold for kansas should be 110" do
    sale = Sale.find(sales(:kansas_spring).id)
    assert_equal(sale.calculate_total_sold, 110, "Items sold for kansas was not 340")
  end
    
  test "total sold for kansas should be 110 after financials are calculated" do
    calculate_all_financials
    sale = Sale.find(sales(:kansas_spring).id)
    assert_equal(sale.total_amount_sold, 110, "Items sold for kansas was not 340")
  end

  test "tax collected for kansas should be 8.8" do
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    assert_equal(sale.tax_received, 8.8, "Items sold for kansas was not 340")
  end

  test "total collected for kansas should be 367.2" do
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    assert_equal(sale.calculate_total_collected, 118.8, "Items sold for kansas was not 340")
  end  

  test "percent fees collected for kansas should be 33" do
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    assert_equal(sale.calculate_percent_fees_collected, 33, "Percent Fees for kansas did not add up")
  end

  test "advertisement fees collected for kansas should be percent 19.5" do
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    assert_equal(sale.calculate_advertisement_fees_collected, 19.5, "Advertisement Fees for kansas did not add up")
  end

  test "check number of consignors for kansas" do
    sale = Sale.find(sales(:kansas_spring).id)
    assert_equal(sale.number_of_consignors, 3, "Number of Consignors for kansas was not 3")    
  end

  test "check number of consignors with sold items for kansas" do
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    assert_equal(sale.calculate_consignors_that_sold_items, 2, "Number of Consignors with sold items for kansas was not 2")    
  end

  test "check number of transactions for kansas" do
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    assert_equal(sale.calculate_number_of_transactions, 2, "Number of Transactions for kansas was not 2")    
  end
    
  test "check extra income for kansas" do    
    sale = Sale.find(sales(:kansas_spring).id)
    assert_equal(sale.extra_income, 0, "Extra Income for kansas was not 0")    
  end

  test "check gross revenue for kansas" do    
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    assert_equal(sale.calculate_gross_revenue, 129.5, "Gross Revenue for kansas was not 129.5")    
  end

  test "check total revenue for kansas" do    
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    assert_equal(sale.calculate_total_revenue, 118.8, "Total Revenue for kansas was not 118.8")    
  end

  test "check gross profit for kansas" do    
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    assert_equal(sale.calculate_gross_profit, 52.5, "Gross Profit for kansas was not 52.5")    
  end

  test "check royalty fee for kansas" do    
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    assert_equal(sale.calculate_royalty_fee, 3.885, "Royalty Fee for kansas was not 13.74")    
  end

  test "check that if the minimum royalty fee applies, the royalty fee is 500" do
    franchise = Franchise.find(2)
    franchise.use_minimum_royalty = true
    franchise.save
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    assert_equal(sale.calculate_royalty_fee, 500, "Royalty Fee for kansas was not the minimum 500")    
  end

  test "adding 30,000 in sales returns the correct royalty" do
    item_count = ConsignorInventory.count
    for i in 1..300
      item = ConsignorInventory.new
      item.price = 100
      item.profile_id = 1
      item.item_description = "New Item #{i}"
      item.size = 1
      item.last_day_discount = false
      item.donate = false
      item.printed = false
      item.bring_to_sale =  true
      item.sale_id = sales(:kansas_spring).id
      item.status = true
      item.sale_price = 100
      item.tax_collected = 24
      item.total_price = 324
      item.sale_date = Date.new(2010, 3, 02)
      item.transaction_number = 4
      item.discounted_at_sale = false
      item.transaction_import_id = 3
      item.rewards_profile_id = rewards_profiles(:rewards_profile_3).id
      item.save
    end
    assert_equal ConsignorInventory.count, item_count + 300
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    assert_equal(sale.calculate_royalty_fee, 904.26, "$#{sale.total_amount_sold} Royalty Fee when 30,000 in sales added did not calculate properly")
  end

  test "adding 30,000 in sales returns the correct royalty when franchise is set for minimum royalty" do
    franchise = Franchise.find(2)
    franchise.use_minimum_royalty = true
    franchise.save
    for i in 1..300
      item = ConsignorInventory.new
      item.price = 100
      item.profile_id = 1
      item.item_description = "New Item #{i}"
      item.size = 1
      item.last_day_discount = false
      item.donate = false
      item.printed = false
      item.bring_to_sale =  true
      item.sale_id = sales(:kansas_spring).id
      item.status = true
      item.sale_price = 100
      item.tax_collected = 24
      item.total_price = 324
      item.sale_date = Date.new(2010, 3, 02)
      item.transaction_number = 4
      item.discounted_at_sale = false
      item.transaction_import_id = 3
      item.rewards_profile_id = rewards_profiles(:rewards_profile_3).id
      item.save
    end
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    assert_equal(sale.calculate_royalty_fee, 904.26, "Royalty Fee when 30,000 in sales added did not calculate properly")
  end

  test "adding 60,000 in sales returns the correct royalty" do
    for i in 1..600
      item = ConsignorInventory.new
      item.price = 100
      item.profile_id = 1
      item.item_description = "New Item #{i}"
      item.size = 1
      item.last_day_discount = false
      item.donate = false
      item.printed = false
      item.bring_to_sale =  true
      item.sale_id = sales(:kansas_spring).id
      item.status = true
      item.sale_price = 100
      item.tax_collected = 24
      item.total_price = 324
      item.sale_date = Date.new(2010, 3, 02)
      item.transaction_number = 4
      item.discounted_at_sale = false
      item.transaction_import_id = 3
      item.rewards_profile_id = rewards_profiles(:rewards_profile_3).id
      item.save
    end
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    assert_equal(sale.calculate_royalty_fee, 1702.84, "Royalty Fee when 60,000 in sales added did not calculate properly")
  end

  test "adding 60,000 in sales returns the correct royalty when franchise is set for minimum royalty" do
    franchise = Franchise.find(2)
    franchise.use_minimum_royalty = true
    franchise.save
    for i in 1..600
      item = ConsignorInventory.new
      item.price = 100
      item.profile_id = 1
      item.item_description = "New Item #{i}"
      item.size = 1
      item.last_day_discount = false
      item.donate = false
      item.printed = false
      item.bring_to_sale =  true
      item.sale_id = sales(:kansas_spring).id
      item.status = true
      item.sale_price = 100
      item.tax_collected = 24
      item.total_price = 324
      item.sale_date = Date.new(2010, 3, 02)
      item.transaction_number = 4
      item.discounted_at_sale = false
      item.transaction_import_id = 3
      item.rewards_profile_id = rewards_profiles(:rewards_profile_3).id
      item.save
    end
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    assert_equal(sale.calculate_royalty_fee, 1702.84, "Royalty Fee when 60,000 in sales added did not calculate properly")
  end


  test "adding 120,000 in sales returns the correct royalty" do
    for i in 1..1200
      item = ConsignorInventory.new
      item.price = 100
      item.profile_id = 1
      item.item_description = "New Item #{i}"
      item.size = 1
      item.last_day_discount = false
      item.donate = false
      item.printed = false
      item.bring_to_sale =  true
      item.sale_id = sales(:kansas_spring).id
      item.status = true
      item.sale_price = 100
      item.tax_collected = 24
      item.total_price = 324
      item.sale_date = Date.new(2010, 3, 02)
      item.transaction_number = 4
      item.discounted_at_sale = false
      item.transaction_import_id = 3
      item.rewards_profile_id = rewards_profiles(:rewards_profile_3).id
      item.save
    end
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    assert_equal(sale.calculate_royalty_fee, 2701.42, "Royalty Fee when 120,000 in sales added did not calculate properly")
  end

  test "adding 120,000 in sales returns the correct royalty when franchise is set for minimum royalty" do
    franchise = Franchise.find(2)
    franchise.use_minimum_royalty = true
    franchise.save
    for i in 1..1200
      item = ConsignorInventory.new
      item.price = 100
      item.profile_id = 1
      item.item_description = "New Item #{i}"
      item.size = 1
      item.last_day_discount = false
      item.donate = false
      item.printed = false
      item.bring_to_sale =  true
      item.sale_id = sales(:kansas_spring).id
      item.status = true
      item.sale_price = 100
      item.tax_collected = 24
      item.total_price = 324
      item.sale_date = Date.new(2010, 3, 02)
      item.transaction_number = 4
      item.discounted_at_sale = false
      item.transaction_import_id = 3
      item.rewards_profile_id = rewards_profiles(:rewards_profile_3).id
      item.save
    end
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    assert_equal(sale.calculate_royalty_fee, 2701.42, "Royalty Fee when 60,000 in sales added did not calculate properly")
  end

  test "check net profit for kansas" do
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    assert_equal(sale.calculate_net_profit, 48.615, "Net profit for kansas ws not 48.62")    
  end
  
  test "items coming to Kansas should be 200" do
    sale = Sale.find(sales(:kansas_spring).id)
    assert_equal(sale.number_of_possible_sale_items, 200, "Number of sale items coming to Kansas was not 200")    
  end

  test "if items coming is set to 400, number_of_possible_sale_items should report 400" do
    sale = Sale.find(sales(:kansas_spring).id)
    sale.items_coming = 400
    sale.save
    sale = Sale.find(sales(:kansas_spring).id)
    assert_equal(sale.number_of_possible_sale_items, 400, "Number of sale items coming to Kansas was not 400")    
  end
  
  test "items coming to Kansas should be 200 even after items are sold" do
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    sale = Sale.find(sales(:kansas_spring).id)
    assert_equal(sale.number_of_possible_sale_items, 200, "Number of sale items coming to Kansas was not 200")    
  end
  
  test "items coming to Kansas should increase by 1 if item marked as coming to sale" do
    item = ConsignorInventory.find(consignor_inventories(:profile_2_un_sold_item_1))
    item.bring_to_sale = true
    item.save
    sale = Sale.find(sales(:kansas_spring).id)
    assert_equal(sale.number_of_possible_sale_items, 201, "Number of sale items coming to Kansas was not 200")    
  end
  
  test "check reward profile ids for kansas" do
    sale = Sale.find(sales(:kansas_spring).id)
    assert_equal(sale.reward_profile_ids, [2, 3], "reward profile ids for kansas did not match")
  end
  
  test "check reward profile ids for florida" do
    sale = Sale.find(sales(:florida_spring).id)
    assert_equal(sale.reward_profile_ids, [2, 3], "reward profile ids for florida did not match") 
  end

  test "check calculate sale for kansas applies rewards correctly for reward profile 1" do
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    assert_equal(sale.amount_purchased_by_rewards_profile(rewards_profiles(:rewards_profile_1).id), 0, "amount calculated for purchase of kansas - reward profile 1 was not 0")
  end

  test "check calculate sale for kansas applies rewards correctly for reward profile 2" do
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    assert_equal(sale.amount_purchased_by_rewards_profile(rewards_profiles(:rewards_profile_2).id), 10.0, "amount calculated for purchase of kansas - reward profile 2 was not 10")
  end

  test "check calculate sale for kansas applies rewards correctly for reward profile 3" do
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    assert_equal(sale.amount_purchased_by_rewards_profile(rewards_profiles(:rewards_profile_3).id), 100.0, "amount calculated for purchase of kansas - reward profile 3 was not 100")
  end

  test "check calculate sale for florida applies rewards correctly for reward profile 1" do
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    assert_equal(sale.amount_purchased_by_rewards_profile(rewards_profiles(:rewards_profile_1).id), 0.0, "amount calculated for purchase of florida - reward profile 1 was not 150")
  end

  test "check calculate sale for florida applies rewards correctly for reward profile 2" do
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    assert_equal(sale.amount_purchased_by_rewards_profile(rewards_profiles(:rewards_profile_2).id), 90.0, "amount calculated for purchase of florida - reward profile 2 was not 90")
  end

  test "check calculate sale for florida applies rewards correctly for reward profile 3" do
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    assert_equal(sale.amount_purchased_by_rewards_profile(rewards_profiles(:rewards_profile_3).id), 250.0, "amount calculated for purchase of florida - reward profile 3 was not 100")
  end

  test "refund item recalculates quantity sold correctly" do
    calculate_all_financials
    item = ConsignorInventory.find(consignor_inventories(:profile_1_item_1).id)
    Sale.calculate_sale_financials_after_refund(item)
    sale = Sale.find(sales(:florida_spring).id)
    assert_equal(sale.total_items_sold, 339, "Items sold for Florida was not 339")
  end

  test "refund item recalculates total amount sold correctly" do
    calculate_all_financials
    item = ConsignorInventory.find(consignor_inventories(:profile_1_item_1).id)
    Sale.calculate_sale_financials_after_refund(item)
    sale = Sale.find(sales(:florida_spring).id)
    assert_equal(sale.total_amount_sold, 339, "Amount sold for Florida was not 339")
  end

  test "refund item recalculates tax received sold correctly" do
    calculate_all_financials
    item = ConsignorInventory.find(consignor_inventories(:profile_1_item_1).id)
    Sale.calculate_sale_financials_after_refund(item)
    sale = Sale.find(sales(:florida_spring).id)
    assert_equal(sale.tax_received, 27.12, "Items sold for Florida was not 339")
  end

  test "refund item recalculates number of transactions correctly" do
    calculate_all_financials
    item = ConsignorInventory.find(consignor_inventories(:profile_1_item_1).id)
    Sale.calculate_sale_financials_after_refund(item)
    sale = Sale.find(sales(:florida_spring).id)
    assert_equal(sale.transaction_count, 3, "Number of Transactions for Florida was not 3")    
  end

  test "refund item recalculates rewards correctly for reward profile 1" do
    calculate_all_financials
    item = ConsignorInventory.find(consignor_inventories(:profile_1_item_1).id)
    Sale.calculate_sale_financials_after_refund(item)
    sale = Sale.find(sales(:florida_spring).id)
    assert_equal(sale.amount_purchased_by_rewards_profile(rewards_profiles(:rewards_profile_3).id), 249.0, "amount calculated for purchase of florida - reward profile 1 was not 149")
  end

  test "next business parnter sort index for kansas spring should be 3" do
    sale = Sale.find(sales(:kansas_spring).id)
    assert_equal sale.next_available_business_partner_sort_index, 3
  end

  test "next business parnter sort index for florida spring should be 1" do
    sale = Sale.find(sales(:florida_spring).id)
    assert_equal sale.next_available_business_partner_sort_index, 1
  end

  test "kansas current has 2 volunteer job shifts" do
    sale = Sale.find(sales(:kansas_current).id)
    assert_equal sale.number_of_volunteer_job_shifts, 7
  end

  test "florida current has 2 volunteer job shifts" do
    sale = Sale.find(sales(:florida_current).id)
    assert_equal sale.number_of_volunteer_job_shifts, 2
  end

  test "kansas current has 2 open volunteer job shifts" do
    sale = Sale.find(sales(:kansas_current).id)
    assert_equal sale.open_volunteer_job_shifts, 7   
  end
  
  test "florida current has 1 open volunteer job shift" do
    sale = Sale.find(sales(:florida_current).id)
    assert_equal sale.open_volunteer_job_shifts, 1  
  end
  
  test "kansas current has 0 filled volunteer job shifts" do
    sale = Sale.find(sales(:kansas_current).id)
    assert_equal sale.filled_volunteer_job_shifts, 0   
  end
  
  test "florida current has 1 filled volunteer job shift" do
    sale = Sale.find(sales(:florida_current).id)
    assert_equal sale.filled_volunteer_job_shifts, 1  
  end
  
  test "kansas current has open volunteer job shifts" do
    sale = Sale.find(sales(:kansas_current).id)
    assert sale.has_open_volunteer_jobs?
  end
  
  test "florida current has open volunteer job shift" do
    sale = Sale.find(sales(:florida_current).id)
    assert sale.has_open_volunteer_jobs?
  end

  test "editing number of slots in florida forces florida to not have open job shifts" do
    sale_volunteer_time = SaleVolunteerTime.find(sale_volunteer_times(:florida_current_2).id)
    sale_volunteer_time.number_of_spots = 2
    sale_volunteer_time.save    
    sale = Sale.find(sales(:florida_current).id)
    assert !sale.has_open_volunteer_jobs?
  end

  test "kansas number of volunteer jobs" do
    sale = Sale.find(sales(:kansas_current).id)
    assert_equal sale.number_of_volunteer_jobs, 70   
  end

  test "florida number of volunteer jobs" do
    sale = Sale.find(sales(:florida_current).id)
    assert_equal sale.number_of_volunteer_jobs, 12
  end    

  test "kansas number of volunteer job spots left" do
    sale = Sale.find(sales(:kansas_current).id)
    assert_equal sale.volunteer_job_spots_left, 62   
  end

  test "florida number of volunteer job spots left" do
    sale = Sale.find(sales(:florida_current).id)
    assert_equal sale.volunteer_job_spots_left, 8
  end    

  test "kansas number of volunteer jobs filled" do
    sale = Sale.find(sales(:kansas_current).id)
    assert_equal sale.volunteer_jobs_filled, 8   
  end

  test "florida number of volunteer jobs filled" do
    sale = Sale.find(sales(:florida_current).id)
    assert_equal sale.volunteer_jobs_filled, 4
  end    

  test "kansas job status is 8 of 70" do
    sale = Sale.find(sales(:kansas_current).id)
    assert_equal sale.volunteer_jobs_status, "8 out of 70"
  end
  
  test "florida job status is 4 of 12" do
    sale = Sale.find(sales(:florida_current).id)
    assert_equal sale.volunteer_jobs_status, "4 out of 12"
  end

  test "editing number of slots in florida forces florida job status to 2 of 2" do
    sale_volunteer_time = SaleVolunteerTime.find(sale_volunteer_times(:florida_current_2).id)
    sale_volunteer_time.number_of_spots = 2
    sale_volunteer_time.save    
    sale = Sale.find(sales(:florida_current).id)
    assert_equal sale.volunteer_jobs_status, "4 out of 4"
  end

  test "editing the sale percentage will update the consignor percentages" do
    sale = Sale.find(sales(:florida_current).id)
    sale.sale_percentage = 65
    assert sale.save
    assert_equal SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_1_florida_current).id).sale_percentage.to_i, 65
    assert_equal SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_3_florida_current).id).sale_percentage.to_i, 65
    assert_equal SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_5_florida_current).id).sale_percentage.to_i, 65
    assert_equal SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_7_florida_current).id).sale_percentage.to_i, 65
  end
#rewards applied
#unique volunteers
#number of volunteers
#number of possible sale items

  def calculate_all_financials
    sales = Sale.find(:all, :order => "start_date ASC")
    for sale in sales
      sale.calculate_financials
    end
  end
end
