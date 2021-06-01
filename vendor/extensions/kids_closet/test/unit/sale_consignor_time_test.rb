require File.dirname(__FILE__) + '/../test_helper'

class SaleConsignorTimeTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  fixtures :sales, :sale_consignor_times
  
  test "check fixtures got loaded" do
    assert_equal 8, SaleConsignorTime.count
  end

  test "a consignor time without a sale id should not save" do
    sale_consignor_time = SaleConsignorTime.new
    sale_consignor_time.number_of_spots = 40
    sale_consignor_time.date = Date.today + 29
    sale_consignor_time.start_time = Time.now + 7200
    sale_consignor_time.end_time = Time.now + 10800
    sale_consignor_time.internal = false  
    assert !sale_consignor_time.save, "a sale saved without the sale id"
    sale_consignor_time.sale_id = sales(:kansas_current).id
    assert sale_consignor_time.save, "adding the sale id did not save the sale"
  end

  test "a consignor time the number of spots should not save" do
    sale_consignor_time = SaleConsignorTime.new
    sale_consignor_time.sale_id = sales(:kansas_current).id
    sale_consignor_time.date = Date.today + 29
    sale_consignor_time.start_time = Time.now + 7200
    sale_consignor_time.end_time = Time.now + 10800
    sale_consignor_time.internal = false  
    assert !sale_consignor_time.save, "a sale saved without the sale number of spots"
    sale_consignor_time.number_of_spots = 40
    assert sale_consignor_time.save, "adding the number of spots did not save the sale"
  end

  test "a consignor time without a date not save" do
    sale_consignor_time = SaleConsignorTime.new
    sale_consignor_time.sale_id = sales(:kansas_current).id
    sale_consignor_time.number_of_spots = 40
    sale_consignor_time.start_time = Time.now + 7200
    sale_consignor_time.end_time = Time.now + 10800
    sale_consignor_time.internal = false  
    assert !sale_consignor_time.save, "a sale saved without the date"
    sale_consignor_time.date = Date.today + 29
    assert sale_consignor_time.save, "adding the date did not save the sale"
  end

  test "a consignor time without a start time not save" do
    sale_consignor_time = SaleConsignorTime.new
    sale_consignor_time.sale_id = sales(:kansas_current).id
    sale_consignor_time.number_of_spots = 40
    sale_consignor_time.date = Date.today + 29
    sale_consignor_time.end_time = Time.now + 10800
    sale_consignor_time.internal = false  
    assert !sale_consignor_time.save, "a sale saved without the start time"
    sale_consignor_time.start_time = Time.now + 7200
    assert sale_consignor_time.save, "adding the start time did not save the sale"
  end

  test "a consignor time without an end time not save" do
    sale_consignor_time = SaleConsignorTime.new
    sale_consignor_time.sale_id = sales(:kansas_current).id
    sale_consignor_time.number_of_spots = 40
    sale_consignor_time.date = Date.today + 29
    sale_consignor_time.start_time = Time.now + 7200
    sale_consignor_time.internal = false  
    assert !sale_consignor_time.save, "a sale saved without the end time"
    sale_consignor_time.end_time = Time.now + 10800
    assert sale_consignor_time.save, "adding the end time did not save the sale"
  end

  test "a sign up time should not have the same start time and date as another sign up time for the same sale" do
    sale_consignor_time = SaleConsignorTime.new
    sale_consignor_time.sale_id = sales(:kansas_current).id
    sale_consignor_time.number_of_spots = 40
    current_consignor_time = sale_consignor_times(:kansas_current_2)
    sale_consignor_time.date = sale_consignor_times(:kansas_current_2).date
    sale_consignor_time.start_time = current_consignor_time.start_time
    sale_consignor_time.end_time = sale_consignor_times(:kansas_current_2).end_time.to_s(:db)
    sale_consignor_time.internal = false  
    assert !sale_consignor_time.save, "a sale saved with a duplicate date/start time combination #{sale_consignor_time.start_time}, #{sale_consignor_time.sale_id}, #{sale_consignor_time.date}"
    sale_consignor_time.start_time = Time.now + 7200
    sale_consignor_time.end_time = Time.now + 10800
    assert sale_consignor_time.save, "changing the times did not save the sale"    
  end

  test "a valid sale consignor time should save" do
    sale_consignor_time = SaleConsignorTime.new
    sale_consignor_time.sale_id = sales(:kansas_current).id
    sale_consignor_time.number_of_spots = 40
    sale_consignor_time.date = Date.today + 29
    sale_consignor_time.start_time = Time.now + 7200
    sale_consignor_time.end_time = Time.now + 10800
    sale_consignor_time.internal = false  
    assert sale_consignor_time.save, "a sale consignor time did not save"
  end
  
  test "a consignor time the number of spots should be a number" do
    sale_consignor_time = SaleConsignorTime.new
    sale_consignor_time.sale_id = sales(:kansas_current).id
    sale_consignor_time.number_of_spots = "forty"
    sale_consignor_time.date = Date.today + 29
    sale_consignor_time.start_time = Time.now + 7200
    sale_consignor_time.end_time = Time.now + 10800
    sale_consignor_time.internal = false  
    assert !sale_consignor_time.save, "a sale saved with an invalid number of spots"
    sale_consignor_time.number_of_spots = 40
    assert sale_consignor_time.save, "adding the number of spots did not save the sale"
  end

  test "a consignor time the number of spots should be an integer" do
    sale_consignor_time = SaleConsignorTime.new
    sale_consignor_time.sale_id = sales(:kansas_current).id
    sale_consignor_time.number_of_spots = 40.5
    sale_consignor_time.date = Date.today + 29
    sale_consignor_time.start_time = Time.now + 7200
    sale_consignor_time.end_time = Time.now + 10800
    sale_consignor_time.internal = false  
    assert !sale_consignor_time.save, "a sale saved with an invalid number of spots"
    sale_consignor_time.number_of_spots = 40
    assert sale_consignor_time.save, "adding the number of spots did not save the sale"
  end

  test "a consignor time the number of spots should be greater than 0" do
    sale_consignor_time = SaleConsignorTime.new
    sale_consignor_time.sale_id = sales(:kansas_current).id
    sale_consignor_time.number_of_spots = -5
    sale_consignor_time.date = Date.today + 29
    sale_consignor_time.start_time = Time.now + 7200
    sale_consignor_time.end_time = Time.now + 10800
    sale_consignor_time.internal = false  
    assert !sale_consignor_time.save, "a sale saved with an invalid number of spots"
    sale_consignor_time.number_of_spots = 40
    assert sale_consignor_time.save, "adding the number of spots did not save the sale"
  end

  test "a consignor time should have an end time greater than the start time" do
    sale_consignor_time = SaleConsignorTime.new
    sale_consignor_time.sale_id = sales(:kansas_current).id
    sale_consignor_time.number_of_spots = 40
    sale_consignor_time.date = Date.today + 29
    sale_consignor_time.start_time = Time.now + 10800
    sale_consignor_time.end_time = Time.now + 7200
    sale_consignor_time.internal = false  
    assert !sale_consignor_time.save, "a sale consignor time saved with end time before start time"
    sale_consignor_time.start_time = Time.now + 7200
    sale_consignor_time.end_time = Time.now + 10800
    assert sale_consignor_time.save, "fixing the times did not save the consignor time"    
  end

  test "when editing an existing time, should not be able to lower the number of slots under the number already signed up" do
    sale_consignor_time = SaleConsignorTime.find(sale_consignor_times(:kansas_current_1).id)
    sale_consignor_time.number_of_spots = 1
    assert !sale_consignor_time.save, "sale saved with number of spots under the limit"
    sale_consignor_time.number_of_spots = 2
    assert sale_consignor_time.save, "fixing the number of spots did not save the sign up time"    
  end

  test "verify number of spots left for kansas current 1" do
    sale_consignor_time = SaleConsignorTime.find(sale_consignor_times(:kansas_current_1).id)
    assert_equal(sale_consignor_time.spots_left, 8, "kansas current 1 does not have 8 spots left")
  end
    
  test "verify number of spots left for kansas current 2" do
    sale_consignor_time = SaleConsignorTime.find(sale_consignor_times(:kansas_current_2).id)
    assert_equal(sale_consignor_time.spots_left, 9, "kansas current 2 does not have 9 spots left")
  end

  test "verify number of spots left for florida current 1" do
    sale_consignor_time = SaleConsignorTime.find(sale_consignor_times(:florida_current_1).id)
    assert_equal(sale_consignor_time.spots_left, 0, "kansas current 1 does not have 0 spots left")
  end
    
  test "verify number of spots left for florida current 2" do
    sale_consignor_time = SaleConsignorTime.find(sale_consignor_times(:florida_current_2).id)
    assert_equal(sale_consignor_time.spots_left, 8, "kansas current 2 does not have 8 spots left")
  end

  test "latest consignor sign up time for kansas current should be kansas current 2" do
    assert_equal(SaleConsignorTime.latest_consignor_time_for_sale(sales(:kansas_current).id), sale_consignor_times(:kansas_current_2), "the wrong time is reported as the latest time for the kansas sale")
  end

  test "latest consignor sign up time for florida current should be florida current 2" do
    assert_equal(SaleConsignorTime.latest_consignor_time_for_sale(sales(:florida_current).id), sale_consignor_times(:florida_current_2), "the wrong time is reported as the latest time for the florida sale")
  end

  test "internal consignor sign up time for kansas current should be kansas current internal" do
    assert_equal(SaleConsignorTime.internal_time_for_sale(sales(:kansas_current).id), sale_consignor_times(:kansas_current_internal).id, "the wrong time is reported as the internal time for the current kansas sale")
  end

  test "internal consignor sign up time for florida current should be florida current internal" do
    assert_equal(SaleConsignorTime.internal_time_for_sale(sales(:florida_current).id), sale_consignor_times(:florida_current_internal).id, "the wrong time is reported as the internal time for the current florida sale")
  end

  test "internal consignor sign up time for kansas spring should be kansas spring internal" do
    assert_equal(SaleConsignorTime.internal_time_for_sale(sales(:kansas_spring).id), sale_consignor_times(:kansas_spring_internal).id, "the wrong time is reported as the internal time for the spring kansas sale")
  end

  test "internal consignor sign up time for florida spring should be florida spring internal" do
    assert_equal(SaleConsignorTime.internal_time_for_sale(sales(:florida_spring).id), sale_consignor_times(:florida_spring_internal).id, "the wrong time is reported as the internal time for the spring florida sale")
  end

  test "items coming to florida current 1 calculates correctly" do
    sale_consignor_time = SaleConsignorTime.find(sale_consignor_times(:florida_current_1).id)
    assert_equal sale_consignor_time.items_coming, 100
  end
end
