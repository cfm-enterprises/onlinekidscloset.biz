require File.dirname(__FILE__) + '/../test_helper'

class FranchiseTest < ActiveSupport::TestCase
  
  fixtures :franchises, :sales
  
  test "check fixtures loaded two franchises" do
    assert_equal 2, Franchise.count
  end

  test "check kansas franchise has correct hash" do
    assert_equal franchises(:kansas).sale_hash, "overland_park__ks"
  end

  test "franchise should not save without franchise name" do
    franchise = Franchise.new
    franchise.franchise_email = "test@kidscloset.biz"
    franchise.sale_city = "test"
    franchise.province_id = 2
    assert !franchise.save, "Saved Franchise without Franchise Name"
    franchise.franchise_name = "My Franchise"
    assert franchise.save, "Adding franchise name did NOT save the franchise"
  end

  test "franchise should not save without city" do
    franchise = Franchise.new
    franchise.franchise_name = "test"
    franchise.franchise_email = "test@kidscloset.biz"
    franchise.province_id = 2
    assert !franchise.save, "Saved Franchise without City"
    franchise.sale_city = "test"
    assert franchise.save, "Adding franchise city did NOT save the franchise"
  end

  test "franchise should not save without province" do
    franchise = Franchise.new
    franchise.franchise_name = "test"
    franchise.franchise_email = "test@kidscloset.biz"
    franchise.sale_city = "test"
    assert !franchise.save, "Saved Franchise without Province"
    franchise.province_id = 2
    assert franchise.save, "Adding province did NOT save the franchise"
  end

  test "franchise should not save without franchise email" do
    franchise = Franchise.new
    franchise.franchise_name = "test"
    franchise.sale_city = "test"
    franchise.province_id = 2
    assert !franchise.save, "Saved Franchise without Email"
    franchise.franchise_email = "tester@cfmenterprises.com"
    assert franchise.save, "Adding franchise email did NOT save the franchise"
  end

  test "franchise should save with hash test" do
    franchise = Franchise.new
    franchise.franchise_name = "test franchise"
    franchise.franchise_email = "test@kidscloset.biz"
    franchise.sale_city = "test"
    franchise.province_id = 2
    assert franchise.save, "Franchise was not saved"
    assert_equal(franchise.sale_hash, "test_franchise", "Incorrect Hash Name")
  end

  test "franchise should not save with duplicate franchise name" do
    franchise = Franchise.new
    franchise.franchise_name = "Florida"
    franchise.franchise_email = "test@kidscloset.biz"
    franchise.sale_city = "test"
    franchise.province_id = 2
    assert !franchise.save, "Franchise saved with duplicate franchise name"
    franchise.franchise_name = "FLORIDA"
    assert !franchise.save, "Franchise saved with duplicate franchise name - case sensitivity failed"    
    franchise.franchise_name = "Florida Franchise"
    franchise.franchise_name = "My Franchise"
    assert franchise.save, "Fixing franchise name did NOT save the franchise"
  end

  test "franchise email should be withing 5-100 characters" do
    franchise = Franchise.new
    franchise.franchise_name = "Florida Franchise"
    franchise.franchise_email = "t@uk"
    franchise.sale_city = "test"
    franchise.province_id = 2
    assert !franchise.save, "Franchise saved with email under five characters"    
    franchise.franchise_email = "abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890@abcdefghijklmnopqrstuvwxyz1234567890.com"
    assert !franchise.save, "Franchise saved with email over 100 characters"    
    franchise.franchise_email = "tester@cfmenterprises.com"
    assert franchise.save, "Fixing franchise email did NOT save the franchise"
  end

  test "franchise email should be valid" do
    franchise = Franchise.new
    franchise.franchise_name = "Florida Franchise"
    franchise.franchise_email = "testcfmenterprises.com"
    franchise.sale_city = "test"
    franchise.province_id = 2
    assert !franchise.save, "Franchise saved with email an invalid email"    
    franchise.franchise_email = "test@cfmenterprises"
    assert !franchise.save, "Franchise saved with email an invalid email"    
    franchise.franchise_email = "test@cfmenterprisescom"
    assert !franchise.save, "Franchise saved with email an invalid email"    
    franchise.franchise_email = "test@cfm_enterprises.com"
    assert !franchise.save, "Franchise saved with email an invalid email"    
    franchise.franchise_email = "tester@cfmenterprises.com"
    assert franchise.save, "Fixing franchise email did NOT save the franchise"
  end

  test "franchise should not save with duplicate sale hash" do
    franchise = Franchise.new
    franchise.franchise_name = "Overland Park..KS"
    franchise.franchise_email = "test@kidscloset.biz"
    franchise.sale_city = "test"
    franchise.province_id = 2
    assert !franchise.save, "Franchise saved with duplicate sale hash"
    franchise.franchise_name = "Overland Park, KS"
    assert !franchise.save, "Franchise saved with duplicate sale hash"
    franchise.franchise_name = "Overland Park  KS"
    assert !franchise.save, "Franchise saved with duplicate sale hash"
    franchise.franchise_name = "Overland Park. KS"
    assert !franchise.save, "Franchise saved with duplicate sale hash"
    franchise.franchise_name = "Overland Park"
    assert franchise.save, "Fixing franchise name did NOT save the franchise"
  end

  test "validate the mini content reader" do
    mini_content = franchises(:florida).mini_content
#    assert_equal(mini_content[0], ["home_content","Home", "This is the home page content"], "Home content was not read properly")
#    assert_equal(mini_content[1], ["about_content","About", "This is the about us content"], "About content was not read properly")
#    assert_equal(mini_content[2], ["contact_content","Contact", "This is the contact us content"], "Contact content was not read properly")
    assert_equal(mini_content[0], ["links_content","Partners", "This is the links area content"], "Partners content was not read properly")
    assert_equal(mini_content[1], ["locations_and_times_content","Dates and Times", "This is the locations and times content"], "Dates/Times content was not read properly")
    assert_equal(mini_content[2], ["charity_content","Charity", "This is the charity content"], "Charity content was not read properly")
    assert_equal(mini_content[3], ["news_content","News", "This is the news content"], "News content was not read properly")
#    assert_equal(mini_content[7], ["incentives_content","Incentives", "This is the incentives content"], "Incentives content was not read properly")
    assert_equal(mini_content[4], ["consignors_info_content","Consignors Info", "This is the consignors info content"], "Consignors Info content was not read properly")
    assert_equal(mini_content[5], ["shoppers_info_content","Shoppers Info", "This is the shoppers info content"], "Shoppers Info content was not read properly")
    assert_equal(mini_content[6], ["volunteers_info_content","Helpers Info", "This is the volunteers info content"], "Helpers Info content was not read properly")
  end

  test "validate active sales reader for franchises" do
    florida = Franchise.find(franchises(:florida).id)
    kansas = Franchise.find(franchises(:kansas).id)
    assert_equal(kansas.active_sale, sales(:kansas_current), "Active sale for Kansas franchise not read correctly")
    assert_equal(florida.active_sale, sales(:florida_current), "Active sale for Florida franchise not read correctly")
  end

  test "validate florida number of consignors in next sale" do
    franchise = Franchise.find(franchises(:florida).id)
    assert_equal franchise.number_of_consignors_in_next_sale, 4
  end
  
  test "validate kansas number of consignors in next sale" do
    franchise = Franchise.find(franchises(:kansas).id)
    assert_equal franchise.number_of_consignors_in_next_sale, 3   
  end

  test "validate florida volunteer job status" do
    franchise = Franchise.find(franchises(:florida).id)
    assert_equal franchise.volunteer_job_status, "4 out of 12"
  end
  
  test "validate kansas volunteer job status" do
    franchise = Franchise.find(franchises(:kansas).id)
    assert_equal franchise.volunteer_job_status, "8 out of 70" 
  end

  test "validate kansas closet cash export file name" do
    franchise = Franchise.find(franchises(:kansas).id)
    assert_equal franchise.closet_cash_export_file_name, "franchise_2_rewards.csv"
  end

  test "validate kansas closet cash export file notification" do
    franchise = Franchise.find(franchises(:kansas).id)
    assert_equal franchise.closet_cash_export_notification, "Your export file can be downloaded from http://www.kidscloset.biz/assets/1/franchise_2_rewards.csv"
  end

  test "validate kansas closet cash export file path" do
    franchise = Franchise.find(franchises(:kansas).id)
    assert_equal franchise.closet_cash_export_path, "#{RAILS_ROOT}/public/assets/1/franchise_2_rewards.csv"
  end
  
  #referred consignors validation
  #other reasons validation
  #how did you hear count validation
  #other reasons count validation
  #active profiles validation
  
end
