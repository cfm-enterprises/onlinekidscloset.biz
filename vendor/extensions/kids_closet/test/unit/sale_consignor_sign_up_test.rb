require File.dirname(__FILE__) + '/../test_helper'

class SaleConsignorSignUpTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  fixtures :sale_consignor_sign_ups, :sale_consignor_times, :franchise_profiles
  
  test "check fixtures got loaded" do
    assert_equal 13, SaleConsignorSignUp.count
  end
  
  test "check profile 1 kansas spring sale name" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_2_kansas_spring).id)
    assert_equal(sign_up.sale_name, "Overland Park, KS (March 01, 2010 - March 03, 2010)", "sale name did not match")
  end
  
  test "check profile 1 kansas spring number of items sold" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_2_kansas_spring).id)
    assert_equal(sign_up.calculate_quantity_sold, 0, "number of items sold did not add up")
  end
  
  test "check profile 1 kansas spring total sold" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_2_kansas_spring).id)
    assert_equal(sign_up.calculate_total_sold, 0, "total sold did not add up")
  end
  
  test "check profile 1 kansas spring consignor share" do
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_2_kansas_spring).id)
    assert_equal(sign_up.consignor_proceeds, 0, "consignor share did not calculate correctly")
  end
  
  test "check profile 1 kansas spring percent fee" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_2_kansas_spring).id)
    assert_equal(sign_up.calculate_percentage_fee, 0, "percent fee did not calculate correctly")
  end
  
  test "check profile 1 kansas spring advertisement fees paid before florida" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_2_kansas_spring).id)
    assert_equal(sign_up.advertisement_fees_paid, 0, "advertisement_fees_paid did not calculate correctly")
  end

  test "check profile 1 kansas spring advertisement fees paid after florida" do
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_2_kansas_spring).id)
    assert_equal(sign_up.advertisement_fees_paid, 12.50, "advertisement_fees_paid did not calculate correctly")
  end

  test "check profile 1 kansas estimated_advertisement_fee before florida" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_2_kansas_spring).id)
    assert_equal(sign_up.estimated_advertisement_fee, 12.50, "estimated advertisement fee did not calculate correctly")
  end
  
  test "check profile 1 kansas estimated_advertisement_fee after florida" do
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_2_kansas_spring).id)
    assert_equal(sign_up.estimated_advertisement_fee, 0, "estimated advertisement fee did not calculate correctly")
  end

  test "check profile 1 kansas spring advertisement fee before florida" do
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_2_kansas_spring).id)
    assert_equal(sign_up.calculate_advertisement_fee, 0, "advertisement fee did not calculate correctly")
  end
  
  test "check profile 1 kansas spring advertisement fee after florida" do
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_2_kansas_spring).id)
    assert_equal(sign_up.calculate_advertisement_fee, 0, "advertisement fee did not calculate correctly")
  end

  test "check profile 1 kansas spring quantity sold after season financials are calculated" do
    calculate_all_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_2_kansas_spring).id)
    assert_equal(sign_up.quantity_sold, 0, "quantity sold did not calculate properly")    
  end

  test "check profile 1 kansas spring total sold after season financials are calculated" do
    calculate_all_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_2_kansas_spring).id)
    assert_equal(sign_up.total_sold, 0, "total sold did not calculate properly")    
  end

  test "check profile 1 kansas spring advertisement fee after season financials are calculated" do
    calculate_all_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_2_kansas_spring).id)
    assert_equal(sign_up.advertisement_fee_paid, 0, "advertisement fee paid did not calculate properly")    
  end

  test "check profile 1 kansas spring percentage fee after season financials are calculated" do
    calculate_all_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_2_kansas_spring).id)
    assert_equal(sign_up.percentage_fee_paid, 0, "percentage fee paid did not calculate properly")    
  end

  test "check profile 1 kansas spring check amount" do
    calculate_all_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_2_kansas_spring).id)
    assert_equal(sign_up.check_amount, 0, "check amount did not calculate correctly")    
  end

  test "check profile 1 florida spring sell name" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_1_florida_spring).id)
    assert_equal(sign_up.sale_name, "Florida (Spring 2010)", "sale name did not match")
  end
  
  test "check profile 1 florida spring number of items sold" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_1_florida_spring).id)
    assert_equal(sign_up.calculate_quantity_sold, 150, "number of items sold did not add up")
  end
  
  test "check profile 1 florida spring number of total sold" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_1_florida_spring).id)
    assert_equal(sign_up.calculate_total_sold, 150.0, "total sold did not add up")
  end
  
  test "check profile 1 florida spring consignor share" do
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_1_florida_spring).id)
    assert_equal(sign_up.consignor_proceeds, 105.0, "consignor share did not calculate correctly")
  end
  
  test "check profile 1 florida spring percentage fee" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_1_florida_spring).id)
    assert_equal(sign_up.calculate_percentage_fee, 45.0, "percent fee did not calculate correctly")
  end
  
  test "check profile 1 florida spring advertisement_fees_paid before kansas" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_1_florida_spring).id)
    assert_equal(sign_up.advertisement_fees_paid, 0, "advertisement_fees_paid did not calculate correctly")
  end

  test "check profile 1 florida spring advertisement_fees_paid after kansas" do
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_1_florida_spring).id)
    assert_equal(sign_up.advertisement_fees_paid, 0, "advertisement_fees_paid did not calculate correctly")
  end
  
  test "check profile 1 florida spring estimated advertisement fee before kansas" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_1_florida_spring).id)
    assert_equal(sign_up.estimated_advertisement_fee, 12.50, "estimated advertisement fee did not calculate correctly")
  end
  
  test "check profile 1 florida spring estimated advertisement fee after kansas" do
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_1_florida_spring).id)
    assert_equal(sign_up.estimated_advertisement_fee, 12.50, "estimated advertisement fee did not calculate correctly")
  end

  test "check profile 1 florida spring advertisement fee before kansas" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_1_florida_spring).id)
    sign_up.sale_consignor_time.sale.calculate_financials
    assert_equal(sign_up.calculate_advertisement_fee, 12.50, "advertisement fee did not calculate correctly")
  end
  
  test "check profile 1 florida spring advertisement fee after kansas" do
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_1_florida_spring).id)
    assert_equal(sign_up.calculate_advertisement_fee, 12.50, "advertisement fee did not calculate correctly")
  end
  
  test "check profile 1 florida spring quantity sold after season financials are calculated" do
    calculate_all_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_1_florida_spring).id)
    assert_equal(sign_up.quantity_sold, 150, "quantity sold did not calculate properly")    
  end

  test "check profile 1 florida spring total sold after season financials are calculated" do
    calculate_all_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_1_florida_spring).id)
    assert_equal(sign_up.total_sold, 150.0, "total sold did not calculate properly")    
  end

  test "check profile 1 florida spring advertisement fee after season financials are calculated" do
    calculate_all_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_1_florida_spring).id)
    assert_equal(sign_up.advertisement_fee_paid, 12.50, "advertisement fee paid did not calculate properly")    
  end

  test "check profile 1 florida spring percentage fee after season financials are calculated" do
    calculate_all_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_1_florida_spring).id)
    assert_equal(sign_up.percentage_fee_paid, 45.0, "percentage fee paid did not calculate properly")    
  end

  test "check profile 1 florida spring check amount" do
    calculate_all_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_1_florida_spring).id)
    assert_equal(sign_up.check_amount, 92.50, "check amount did not calculate correctly")    
  end

  test "refund item recalculates quantity sold correctly" do
    calculate_all_financials
    item = ConsignorInventory.find(consignor_inventories(:profile_1_item_1).id)
    Sale.calculate_sale_financials_after_refund(item)
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_1_florida_spring).id)
    assert_equal(sign_up.quantity_sold, 149, "quantity sold did not calculate properly")    
  end

  test "refund item recalculates total sold correctly" do
    calculate_all_financials
    item = ConsignorInventory.find(consignor_inventories(:profile_1_item_1).id)
    Sale.calculate_sale_financials_after_refund(item)
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_1_florida_spring).id)
    assert_equal(sign_up.total_sold, 149, "quantity sold did not calculate properly")    
  end

  test "refund item recalculates advertisement fee correctly" do
    calculate_all_financials
    item = ConsignorInventory.find(consignor_inventories(:profile_1_item_1).id)
    Sale.calculate_sale_financials_after_refund(item)
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_1_florida_spring).id)
    assert_equal(sign_up.advertisement_fee_paid, 12.50, "advertisement fee did not calculate properly")    
  end

  test "refund item recalculates percentage fee correctly" do
    calculate_all_financials
    item = ConsignorInventory.find(consignor_inventories(:profile_1_item_1).id)
    Sale.calculate_sale_financials_after_refund(item)
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_1_florida_spring).id)
    assert_equal(sign_up.percentage_fee_paid, 44.70, "percentage fee did not calculate properly")    
  end

  test "check profile 2 kansas spring number of items sold" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_4_kansas_spring).id)
    assert_equal(sign_up.calculate_quantity_sold, 10, "number of items sold did not add up")
  end
  
  test "check profile 2 kansas spring total sold" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_4_kansas_spring).id)
    assert_equal(sign_up.calculate_total_sold, 10.0, "total sold did not add up")
  end
  
  test "check profile 2 kansas spring consignor share" do
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_4_kansas_spring).id)
    assert_equal(sign_up.consignor_proceeds, 7.0, "consignor share did not calculate correctly")
  end
  
  test "check profile 2 kansas spring percent fee" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_4_kansas_spring).id)
    assert_equal(sign_up.calculate_percentage_fee, 3.0, "percent fee did not calculate correctly")
  end
  
  test "check profile 2 kansas spring advertisement fees paid before florida" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_4_kansas_spring).id)
    assert_equal(sign_up.advertisement_fees_paid, 0, "advertisement fees paid did not calculate correctly")
  end
  
  test "check profile 2 kansas spring advertisement fees paid after florida" do
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_4_kansas_spring).id)
    assert_equal(sign_up.advertisement_fees_paid, 12.50, "advertisement fees paid did not calculate correctly")
  end
  
  test "check profile 2 kansas spring estimated advertisement fee before florida" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_4_kansas_spring).id)
    assert_equal(sign_up.estimated_advertisement_fee, 12.50, "estimated advertisement fee did not calculate correctly")
  end
  
  test "check profile 2 kansas spring estimated advertisement fee after florida" do
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_4_kansas_spring).id)
    assert_equal(sign_up.estimated_advertisement_fee, 0, "estimated advertisement fee did not calculate correctly")
  end

  test "check profile 2 kansas spring advertisement fee before florida" do
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_4_kansas_spring).id)
    assert_equal(sign_up.calculate_advertisement_fee, 7.0, "advertisement fee did not calculate correctly")
  end
  
  test "check profile 2 kansas spring advertisement fee after florida" do
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_4_kansas_spring).id)
    assert_equal(sign_up.calculate_advertisement_fee, 0, "advertisement fee did not calculate correctly")
  end

  test "check profile 2 kansas spring quantity sold after season financials are calculated" do
    calculate_all_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_4_kansas_spring).id)
    assert_equal(sign_up.quantity_sold, 10, "quantity sold did not calculate properly")    
  end

  test "check profile 2 kansas spring total sold after season financials are calculated" do
    calculate_all_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_4_kansas_spring).id)
    assert_equal(sign_up.total_sold, 10.0, "total sold did not calculate properly")    
  end

  test "check profile 2 kansas spring advertisement fee after season financials are calculated" do
    calculate_all_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_4_kansas_spring).id)
    assert_equal(sign_up.advertisement_fee_paid, 7.0, "advertisement fee paid did not calculate properly")    
  end
  
  test "check profile 2 kansas spring percentage fee after season financials are calculated" do
    calculate_all_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_4_kansas_spring).id)
    assert_equal(sign_up.percentage_fee_paid, 3.0, "percentage fee paid did not calculate properly")    
  end

  test "check profile 2 kansas spring check amount" do
    calculate_all_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_4_kansas_spring).id)
    assert_equal(sign_up.check_amount, 0, "check amount did not calculate correctly")    
  end

  test "check profile 2 florida spring number of items sold" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_3_florida_spring).id)
    assert_equal(sign_up.calculate_quantity_sold, 90, "number of items sold did not add up")
  end
  
  test "check profile 2 florida spring number of total sold" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_3_florida_spring).id)
    assert_equal(sign_up.calculate_total_sold, 90.0, "total sold did not add up")
  end
  
  test "check profile 2 florida spring consignor share" do
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_3_florida_spring).id)
    assert_equal(sign_up.consignor_proceeds, 63.0, "consignor share did not calculate correctly")
  end
  
  test "check profile 2 florida spring percentage fee" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_3_florida_spring).id)
    assert_equal(sign_up.calculate_percentage_fee, 27.0, "percent fee did not calculate correctly")
  end
  
  test "check profile 2 florida spring advertisement fees paid before kansas" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_3_florida_spring).id)
    assert_equal(sign_up.advertisement_fees_paid, 0, "advertisement fees paid did not calculate correctly")
  end
  
  test "check profile 2 florida spring advertisement fees paid after kansas" do
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_3_florida_spring).id)
    assert_equal(sign_up.advertisement_fees_paid, 7.0, "advertisement fees paid did not calculate correctly")
  end

  test "check profile 2 florida spring estimated advertisement fee before kansas" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_3_florida_spring).id)
    assert_equal(sign_up.estimated_advertisement_fee, 12.50, "estimated advertisement fee did not calculate correctly")
  end
  
  test "check profile 2 florida spring estimated advertisement fee after kansas" do
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_3_florida_spring).id)
    assert_equal(sign_up.estimated_advertisement_fee, 5.50, "estimated advertisement fee did not calculate correctly")
  end
  
  test "check profile 2 florida spring advertisement fee before kansas" do
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_3_florida_spring).id)
    assert_equal(sign_up.calculate_advertisement_fee, 12.50, "advertisement fee did not calculate correctly")
  end
  
  test "check profile 2 florida spring advertisement fee after kansas" do
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_3_florida_spring).id)
    assert_equal(sign_up.calculate_advertisement_fee, 5.50, "advertisement fee did not calculate correctly")
  end
  
  test "check profile 2 florida spring quantity sold after season financials are calculated" do
    calculate_all_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_3_florida_spring).id)
    assert_equal(sign_up.quantity_sold, 90, "quantity sold did not calculate properly")    
  end

  test "check profile 2 florida spring total sold after season financials are calculated" do
    calculate_all_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_3_florida_spring).id)
    assert_equal(sign_up.total_sold, 90.0, "total sold did not calculate properly")    
  end

  test "check profile 2 florida spring advertisement fee after season financials are calculated" do
    calculate_all_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_3_florida_spring).id)
    assert_equal(sign_up.advertisement_fee_paid, 5.50, "advertisement fee paid did not calculate properly")    
  end
  
  test "check profile 2 florida spring percentage fee after season financials are calculated" do
    calculate_all_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_3_florida_spring).id)
    assert_equal(sign_up.percentage_fee_paid, 27.0, "percentage fee paid did not calculate properly")    
  end

  test "check profile 2 florida spring check amount" do
    calculate_all_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_3_florida_spring).id)
    assert_equal(sign_up.check_amount, 57.50, "check amount did not calculate correctly")    
  end

  test "check profile 3 kansas spring number of items sold" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_6_kansas_spring).id)
    assert_equal(sign_up.calculate_quantity_sold, 100, "number of items sold did not add up")
  end
  
  test "check profile 3 kansas spring total sold" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_6_kansas_spring).id)
    assert_equal(sign_up.calculate_total_sold, 100.0, "total sold did not add up")
  end
  
  test "check profile 3 kansas spring consignor share" do
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_6_kansas_spring).id)
    assert_equal(sign_up.consignor_proceeds, 70.0, "consignor share did not calculate correctly")
  end
  
  test "check profile 3 kansas spring percent fee" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_6_kansas_spring).id)
    assert_equal(sign_up.calculate_percentage_fee, 30.0, "percent fee did not calculate correctly")
  end
  
  test "check profile 3 kansas spring advertisement fees paid before florida" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_6_kansas_spring).id)
    assert_equal(sign_up.advertisement_fees_paid, 0, "advertisement fees paid did not calculate correctly")
  end
  
  test "check profile 3 kansas spring advertisement fees paid after florida" do
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_6_kansas_spring).id)
    assert_equal(sign_up.advertisement_fees_paid, 12.50, "advertisement fees paid did not calculate correctly")
  end
  
  test "check profile 3 kansas spring estimated advertisement fee before florida" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_6_kansas_spring).id)
    assert_equal(sign_up.estimated_advertisement_fee, 12.50, "estimated advertisement fee did not calculate correctly")
  end
  
  test "check profile 3 kansas spring estimated advertisement fee after florida" do
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_6_kansas_spring).id)
    assert_equal(sign_up.estimated_advertisement_fee, 0, "estimated advertisement fee did not calculate correctly")
  end
  
  test "check profile 3 kansas spring advertisement fee before kansas" do
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_6_kansas_spring).id)
    assert_equal(sign_up.calculate_advertisement_fee, 12.50, "advertisement fee did not calculate correctly")
  end
  
  test "check profile 3 kansas spring advertisement fee after kansas" do
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_6_kansas_spring).id)
    assert_equal(sign_up.calculate_advertisement_fee, 0, "advertisement fee did not calculate correctly")
  end

  test "check profile 3 kansas spring quantity sold after season financials are calculated" do
    calculate_all_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_6_kansas_spring).id)
    assert_equal(sign_up.quantity_sold, 100, "quantity sold did not calculate properly")    
  end

  test "check profile 3 kansas spring total sold after season financials are calculated" do
    calculate_all_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_6_kansas_spring).id)
    assert_equal(sign_up.total_sold, 100.0, "total sold did not calculate properly")    
  end

  test "check profile 3 kansas spring advertisement fee after season financials are calculated" do
    calculate_all_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_6_kansas_spring).id)
    assert_equal(sign_up.advertisement_fee_paid, 12.50, "advertisement fee paid did not calculate properly")    
  end

  test "check profile 3 kansas spring percentage fee after season financials are calculated" do
    calculate_all_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_6_kansas_spring).id)
    assert_equal(sign_up.percentage_fee_paid, 30.0, "percentage fee paid did not calculate properly")    
  end

  test "check profile 3 kansas spring check amount" do
    calculate_all_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_6_kansas_spring).id)
    assert_equal(sign_up.check_amount, 57.50, "check amount did not calculate correctly")    
  end

  test "check profile 3 florida spring number of items sold" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_5_florida_spring).id)
    assert_equal(sign_up.calculate_quantity_sold, 100, "number of items sold did not add up")
  end
  
  test "check profile 3 florida spring number of total sold" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_5_florida_spring).id)
    assert_equal(sign_up.calculate_total_sold, 100.0, "total sold did not add up")
  end
  
  test "check profile 3 florida spring consignor share" do
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_5_florida_spring).id)
    assert_equal(sign_up.consignor_proceeds, 70.0, "consignor share did not calculate correctly")
  end
  
  test "check profile 3 florida spring percentage fee" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_5_florida_spring).id)
    assert_equal(sign_up.calculate_percentage_fee, 30.0, "percent fee did not calculate correctly")
  end
  
  test "check profile 3 florida spring advertisement fees paid before kansas" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_5_florida_spring).id)
    assert_equal(sign_up.advertisement_fees_paid, 0, "advertisement fees paid did not calculate correctly")
  end
  
  test "check profile 3 florida spring advertisement fees paid after kansas" do
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_5_florida_spring).id)
    assert_equal(sign_up.advertisement_fees_paid, 12.50, "advertisement fees paid did not calculate correctly")
  end
  
  test "check profile 3 florida spring estimated advertisement fee before kansas" do
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_5_florida_spring).id)
    assert_equal(sign_up.estimated_advertisement_fee, 12.50, "estimated advertisement fee did not calculate correctly")
  end
  
  test "check profile 3 florida spring estimated advertisement fee after kansas" do
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_5_florida_spring).id)
    assert_equal(sign_up.estimated_advertisement_fee, 0, "estimated advertisement fee did not calculate correctly")
  end
  
  test "check profile 3 florida spring advertisement fee before kansas" do
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_5_florida_spring).id)
    assert_equal(sign_up.calculate_advertisement_fee, 12.50, "advertisement fee did not calculate correctly")
  end
  
  test "check profile 3 florida spring advertisement fee after kansas" do
    sale = Sale.find(sales(:kansas_spring).id)
    sale.calculate_financials
    sale = Sale.find(sales(:florida_spring).id)
    sale.calculate_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_5_florida_spring).id)
    assert_equal(sign_up.calculate_advertisement_fee, 0, "advertisement fee did not calculate correctly")
  end
  
  test "check profile 3 florida spring quantity sold after season financials are calculated" do
    calculate_all_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_5_florida_spring).id)
    assert_equal(sign_up.quantity_sold, 100, "quantity sold did not calculate properly")    
  end

  test "check profile 3 florida spring total sold after season financials are calculated" do
    calculate_all_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_5_florida_spring).id)
    assert_equal(sign_up.total_sold, 100.0, "total sold did not calculate properly")    
  end

  test "check profile 3 florida spring advertisement fee after season financials are calculated" do
    calculate_all_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_5_florida_spring).id)
    assert_equal(sign_up.advertisement_fee_paid, 0, "advertisement fee paid did not calculate properly")    
  end
  
  test "check profile 3 florida spring percentage fee after season financials are calculated" do
    calculate_all_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_5_florida_spring).id)
    assert_equal(sign_up.percentage_fee_paid, 30.0, "percentage fee paid did not calculate properly")    
  end

  test "check profile 3 florida spring check amount" do
    calculate_all_financials
    sign_up = SaleConsignorSignUp.find(sale_consignor_sign_ups(:franchise_profile_5_florida_spring).id)
    assert_equal(sign_up.check_amount, 70.0, "check amount did not calculate correctly")    
  end

  test "a valid consignor sign up time should save" do
    sale_consignor_sign_up = SaleConsignorSignUp.new
    sale_consignor_sign_up.sale_consignor_time_id = sale_consignor_times(:florida_current_2).id
    sale_consignor_sign_up.franchise_profile_id = franchise_profiles(:consignor_5_florida).id
    assert sale_consignor_sign_up.save, "a valid sign up did not save"
  end

  test "a new consignor signing up for the florida current 1 time should not be allowed" do
    sale_consignor_sign_up = SaleConsignorSignUp.new
    sale_consignor_sign_up.sale_consignor_time_id = sale_consignor_times(:florida_current_1).id
    sale_consignor_sign_up.franchise_profile_id = franchise_profiles(:consignor_5_florida).id
    sale_consignor_sign_up.sale_advert_cost = 12.50
    sale_consignor_sign_up.sale_percentage = 70
    assert !sale_consignor_sign_up.save, "a sign up over the number of slots allowed saved"
    #move to another time, should save
    other_sale_consignor_sign_up = SaleConsignorSignUp.new
    other_sale_consignor_sign_up.sale_consignor_time_id = sale_consignor_times(:florida_current_2).id
    other_sale_consignor_sign_up.franchise_profile_id = franchise_profiles(:consignor_5_florida).id
    other_sale_consignor_sign_up.sale_advert_cost = 12.50
    other_sale_consignor_sign_up.sale_percentage = 70
    assert other_sale_consignor_sign_up.save, "A brand new consignor sign up time did not save the sign up"
    sale_consignor_sign_up.sale_consignor_time = sale_consignor_times(:florida_current_2)
    assert other_sale_consignor_sign_up.save, "Changing the sign up time did not save the sign up"
  end

  def calculate_all_financials
    sales = Sale.find(:all, :order => "start_date ASC")
    for sale in sales
      sale.calculate_financials
    end
  end
end
