require File.dirname(__FILE__) + '/../test_helper'

class SaleVolunteerTimeTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  fixtures :sales, :sale_volunteer_times
  
  test "check fixtures got loaded" do
    assert_equal 9, SaleVolunteerTime.count
  end

  test "a volunteer time without a sale id should not save" do
    sale_volunteer_time = SaleVolunteerTime.new
    sale_volunteer_time.number_of_spots = 40
    sale_volunteer_time.date = Date.today + 29
    sale_volunteer_time.start_time = Time.now + 7200
    sale_volunteer_time.end_time = Time.now + 10800
    sale_volunteer_time.job_title = "Cashier"
    assert !sale_volunteer_time.save, "a volunteer time saved without the sale id"
    sale_volunteer_time.sale_id = sales(:kansas_current).id
    assert sale_volunteer_time.save, "adding the sale id did not save the volunteer time"
  end

  test "a volunteer time the number of spots should not save" do
    sale_volunteer_time = SaleVolunteerTime.new
    sale_volunteer_time.sale_id = sales(:kansas_current).id
    sale_volunteer_time.date = Date.today + 29
    sale_volunteer_time.start_time = Time.now + 7200
    sale_volunteer_time.end_time = Time.now + 10800
    sale_volunteer_time.job_title = "Cashier"
    assert !sale_volunteer_time.save, "a volunteer time saved without the sale number of spots"
    sale_volunteer_time.number_of_spots = 40
    assert sale_volunteer_time.save, "adding the number of spots did not save the volunteer time"
  end

  test "a volunteer time without a date not save" do
    sale_volunteer_time = SaleVolunteerTime.new
    sale_volunteer_time.sale_id = sales(:kansas_current).id
    sale_volunteer_time.number_of_spots = 40
    sale_volunteer_time.start_time = Time.now + 7200
    sale_volunteer_time.end_time = Time.now + 10800
    sale_volunteer_time.job_title = "Cashier"  
    assert !sale_volunteer_time.save, "a volunteer time saved without the date"
    sale_volunteer_time.date = Date.today + 29
    assert sale_volunteer_time.save, "adding the date did not save the volunteer time"
  end

  test "a volunteer time without a start time not save" do
    sale_volunteer_time = SaleVolunteerTime.new
    sale_volunteer_time.sale_id = sales(:kansas_current).id
    sale_volunteer_time.number_of_spots = 40
    sale_volunteer_time.date = Date.today + 29
    sale_volunteer_time.end_time = Time.now + 10800
    sale_volunteer_time.job_title = "Cashier"  
    assert !sale_volunteer_time.save, "a volunteer time saved without the start time"
    sale_volunteer_time.start_time = Time.now + 7200
    assert sale_volunteer_time.save, "adding the start time did not save the volunteer time"
  end

  test "a volunteer time without an end time not save" do
    sale_volunteer_time = SaleVolunteerTime.new
    sale_volunteer_time.sale_id = sales(:kansas_current).id
    sale_volunteer_time.number_of_spots = 40
    sale_volunteer_time.date = Date.today + 29
    sale_volunteer_time.start_time = Time.now + 7200
    sale_volunteer_time.job_title = "Cashier"  
    assert !sale_volunteer_time.save, "a volunteer time saved without the end time"
    sale_volunteer_time.end_time = Time.now + 10800
    assert sale_volunteer_time.save, "adding the end time did not save the volunteer time"
  end

  test "a volunteer time without a job title should not save" do
    sale_volunteer_time = SaleVolunteerTime.new
    sale_volunteer_time.sale_id = sales(:kansas_current).id
    sale_volunteer_time.number_of_spots = 40
    sale_volunteer_time.date = Date.today + 29
    sale_volunteer_time.start_time = Time.now + 7200
    sale_volunteer_time.end_time = Time.now + 10800
    assert !sale_volunteer_time.save, "a volunteer time saved without the job title"
    sale_volunteer_time.job_title = "Cashier"  
    assert sale_volunteer_time.save, "adding the job title did not save the volunteer time"
  end

  test "a valid sale volunteer time should save" do
    sale_volunteer_time = SaleVolunteerTime.new
    sale_volunteer_time.sale_id = sales(:kansas_current).id
    sale_volunteer_time.number_of_spots = 40
    sale_volunteer_time.date = Date.today + 29
    sale_volunteer_time.start_time = Time.now + 7200
    sale_volunteer_time.end_time = Time.now + 10800
    sale_volunteer_time.job_title = "Cashier"  
    assert sale_volunteer_time.save, "a sale volunteer time did not save"
  end
  
  test "a volunteer time the number of spots should be a number" do
    sale_volunteer_time = SaleVolunteerTime.new
    sale_volunteer_time.sale_id = sales(:kansas_current).id
    sale_volunteer_time.number_of_spots = "forty"
    sale_volunteer_time.date = Date.today + 29
    sale_volunteer_time.start_time = Time.now + 7200
    sale_volunteer_time.end_time = Time.now + 10800
    sale_volunteer_time.job_title = "Cashier"  
    assert !sale_volunteer_time.save, "a volunteer timewith an invalid number of spots"
    sale_volunteer_time.number_of_spots = 40
    assert sale_volunteer_time.save, "adding the number of spots did not save the volunteer time"
  end

  test "a volunteer time the number of spots should be an integer" do
    sale_volunteer_time = SaleVolunteerTime.new
    sale_volunteer_time.sale_id = sales(:kansas_current).id
    sale_volunteer_time.number_of_spots = 40.5
    sale_volunteer_time.date = Date.today + 29
    sale_volunteer_time.start_time = Time.now + 7200
    sale_volunteer_time.end_time = Time.now + 10800
    sale_volunteer_time.job_title = "Cashier"  
    assert !sale_volunteer_time.save, "a volunteer timewith an invalid number of spots"
    sale_volunteer_time.number_of_spots = 40
    assert sale_volunteer_time.save, "adding the number of spots did not save the volunteer time"
  end

  test "a volunteer time the number of spots should be greater than 0" do
    sale_volunteer_time = SaleVolunteerTime.new
    sale_volunteer_time.sale_id = sales(:kansas_current).id
    sale_volunteer_time.number_of_spots = -5
    sale_volunteer_time.date = Date.today + 29
    sale_volunteer_time.start_time = Time.now + 7200
    sale_volunteer_time.end_time = Time.now + 10800
    sale_volunteer_time.job_title = "Cashier"  
    assert !sale_volunteer_time.save, "a volunteer timewith an invalid number of spots"
    sale_volunteer_time.number_of_spots = 40
    assert sale_volunteer_time.save, "adding the number of spots did not save the volunteer time"
  end

  test "a volunteer time should have an end time greater than the start time" do
    sale_volunteer_time = SaleVolunteerTime.new
    sale_volunteer_time.sale_id = sales(:kansas_current).id
    sale_volunteer_time.number_of_spots = 40
    sale_volunteer_time.date = Date.today + 29
    sale_volunteer_time.start_time = Time.now + 10800
    sale_volunteer_time.end_time = Time.now + 7200
    sale_volunteer_time.job_title = "Cashier"  
    assert !sale_volunteer_time.save, "a sale volunteer time saved with end time before start time"
    sale_volunteer_time.start_time = Time.now + 7200
    sale_volunteer_time.end_time = Time.now + 10800
    assert sale_volunteer_time.save, "fixing the times did not save the volunteer time"    
  end

  test "when editing an existing time, should not be able to lower the number of slots under the number already signed up" do
    sale_volunteer_time = SaleVolunteerTime.find(sale_volunteer_times(:kansas_current_1).id)
    sale_volunteer_time.number_of_spots = 1
    assert !sale_volunteer_time.save, "sale saved with number of spots under the limit"
    sale_volunteer_time.number_of_spots = 2
    assert sale_volunteer_time.save, "fixing the number of spots did not save the sign up time"    
  end

  test "verify number of spots left for kansas current 1" do
    sale_volunteer_time = SaleVolunteerTime.find(sale_volunteer_times(:kansas_current_1).id)
    assert_equal(sale_volunteer_time.spots_left, 8, "kansas current 1 does not have 8 spots left")
  end
    
  test "verify number of spots left for kansas current 2" do
    sale_volunteer_time = SaleVolunteerTime.find(sale_volunteer_times(:kansas_current_2).id)
    assert_equal(sale_volunteer_time.spots_left, 8, "kansas current 2 does not have 8 spots left")
  end

  test "verify number of spots left for florida current 1" do
    sale_volunteer_time = SaleVolunteerTime.find(sale_volunteer_times(:florida_current_1).id)
    assert_equal(sale_volunteer_time.spots_left, 0, "florida current 1 does not have 0 spots left")
  end
    
  test "verify number of spots left for florida current 2" do
    sale_volunteer_time = SaleVolunteerTime.find(sale_volunteer_times(:florida_current_2).id)
    assert_equal(sale_volunteer_time.spots_left, 8, "florida current 2 does not have 8 spots left")
  end

  test "verify florida current 1 is full" do 
    sale_volunteer_time = SaleVolunteerTime.find(sale_volunteer_times(:florida_current_1).id)
    assert sale_volunteer_time.is_full?
  end

  test "verify florida current 2 is not full" do 
    sale_volunteer_time = SaleVolunteerTime.find(sale_volunteer_times(:florida_current_2).id)
    assert !sale_volunteer_time.is_full?
  end

  test "verify florida current 1 is not open" do 
    sale_volunteer_time = SaleVolunteerTime.find(sale_volunteer_times(:florida_current_1).id)
    assert !sale_volunteer_time.is_open?
  end

  test "verify florida current 2 is open" do 
    sale_volunteer_time = SaleVolunteerTime.find(sale_volunteer_times(:florida_current_2).id)
    assert sale_volunteer_time.is_open?
  end

  test "latest consignor sign up time for kansas current should be kansas current 9" do
    assert_equal(SaleVolunteerTime.latest_volunteer_time_for_sale(sales(:kansas_current).id), sale_volunteer_times(:kansas_current_4), "the wrong time is reported as the latest volunteer time for the kansas sale")
  end

  test "latest consignor sign up time for florida current should be florida current 2" do
    assert_equal(SaleVolunteerTime.latest_volunteer_time_for_sale(sales(:florida_current).id), sale_volunteer_times(:florida_current_2), "the wrong time is reported as the latest volunteer time for the florida sale")
  end
end
