require File.dirname(__FILE__) + '/../test_helper'

class BusinessPartnerTest < ActiveSupport::TestCase
  # Replace this with your real tests.

  fixtures :sales, :business_partners

  test "check fixtures got loaded" do
    assert_equal 2, BusinessPartner.count
  end

  test "business partner must belong to a sale" do
    business_partner = BusinessPartner.new
    business_partner.partner_title = "Business Partner"
    business_partner.partner_url = "www.domain.com"
    business_partner.partner_description = "Test Partner"
    business_partner.sort_index = 1
    assert !business_partner.save, "sale saved without a sale"
    business_partner.sale_id = sales(:florida_spring).id
    assert business_partner.save, "adding sale did not save the business partner"
  end

  test "business partner must have a title" do
    business_partner = BusinessPartner.new
    business_partner.sale_id = sales(:florida_spring).id
    business_partner.partner_url = "www.domain.com"
    business_partner.partner_description = "Test Partner"
    business_partner.sort_index = 1
    assert !business_partner.save, "sale saved without a title"
    business_partner.partner_title = "Business Partner"
    assert business_partner.save, "adding title did not save the business partner"
  end

  test "business partner must have a unique title" do
    business_partner = BusinessPartner.new
    business_partner.sale_id = sales(:florida_spring).id
    business_partner.partner_url = "www.domain.com"
    business_partner.partner_description = "CFM Enterprises"
    business_partner.sort_index = 1
    assert !business_partner.save, "sale saved with a duplicate title"
    business_partner.partner_title = "Business Partner"
    assert business_partner.save, "fixing title did not save the business partner"
  end

  test "business partner must have a url" do
    business_partner = BusinessPartner.new
    business_partner.sale_id = sales(:florida_spring).id
    business_partner.partner_title = "Business Partner"
    business_partner.partner_description = "Test Partner"
    business_partner.sort_index = 1
    assert !business_partner.save, "sale saved without a url"
    business_partner.partner_url = "www.domain.com"
    assert business_partner.save, "adding url did not save the business partner"
  end

  test "business partner must have a description" do
    business_partner = BusinessPartner.new
    business_partner.sale_id = sales(:florida_spring).id
    business_partner.partner_title = "Business Partner"
    business_partner.partner_url = "www.domain.com"
    business_partner.sort_index = 1
    assert !business_partner.save, "sale saved without a description"
    business_partner.partner_description = "Test Partner"
    assert business_partner.save, "adding description did not save the business partner"
  end
  
  test "business partner must have a sort index" do
    business_partner = BusinessPartner.new
    business_partner.sale_id = sales(:florida_spring).id
    business_partner.partner_title = "Business Partner"
    business_partner.partner_url = "www.domain.com"
    business_partner.partner_description = "Test Partner"
    assert !business_partner.save, "sale saved without a sort index"
    business_partner.sort_index = 1
    assert business_partner.save, "adding sort index did not save the business partner"
  end

  test "business partner must have a sort index be a number" do
    business_partner = BusinessPartner.new
    business_partner.sale_id = sales(:florida_spring).id
    business_partner.partner_title = "Business Partner"
    business_partner.partner_url = "www.domain.com"
    business_partner.partner_description = "Test Partner"
    business_partner.sort_index = "abc"
    assert !business_partner.save, "sale saved without a alphanumeric sort index"
    business_partner.sort_index = 1
    assert business_partner.save, "fixing sort index did not save the business partner"
  end

  test "business partner must have a sort index be a positive" do
    business_partner = BusinessPartner.new
    business_partner.sale_id = sales(:florida_spring).id
    business_partner.partner_title = "Business Partner"
    business_partner.partner_url = "www.domain.com"
    business_partner.partner_description = "Test Partner"
    business_partner.sort_index = -5
    assert !business_partner.save, "sale saved with a negative sort index"
    business_partner.sort_index = 1
    assert business_partner.save, "fixing sort index did not save the business partner"
  end

  test "business partner must have a sort index not be 0" do
    business_partner = BusinessPartner.new
    business_partner.sale_id = sales(:florida_spring).id
    business_partner.partner_title = "Business Partner"
    business_partner.partner_url = "www.domain.com"
    business_partner.partner_description = "Test Partner"
    business_partner.sort_index = 0
    assert !business_partner.save, "sale saved with a 0 sort index"
    business_partner.sort_index = 1
    assert business_partner.save, "fixing sort index did not save the business partner"
  end

  test "business partner must have a sort index be a positive integer" do
    business_partner = BusinessPartner.new
    business_partner.sale_id = sales(:florida_spring).id
    business_partner.partner_title = "Business Partner"
    business_partner.partner_url = "www.domain.com"
    business_partner.partner_description = "Test Partner"
    business_partner.sort_index = 5.583
    assert !business_partner.save, "sale saved with a decimal sort index"
    business_partner.sort_index = 1
    assert business_partner.save, "fixing sort index did not save the business partner"
  end

  test "a valid busienss partner should save" do
    business_partner = BusinessPartner.new
    business_partner.sale_id = sales(:florida_spring).id
    business_partner.partner_title = "Business Partner"
    business_partner.partner_url = "www.domain.com"
    business_partner.partner_description = "Test Partner"
    business_partner.sort_index = 1
    assert business_partner.save, "a valid business partner did not save"
  end

  test "link url computes correctly" do
    business_partner = business_partners(:kansas_spring_partner_1)
    assert_equal business_partner.link_url, "http://www.cfmenterprises.com"
  end

end
