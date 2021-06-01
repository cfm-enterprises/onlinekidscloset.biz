require File.dirname(__FILE__) + '/../test_helper'

class KidsEmailTest < ActiveSupport::TestCase
  # Replace this with your real tests.

  test "can't save eail without subject" do
  	email = KidsEmail.new
  	email.recipients = "everyone"
  	email.html_body = "<b>Hello</b>"
  	email.text_body = "Hello"
  	email.franchise_id = 1
  	assert !email.save, "Email saved without a subject"
  	email.subject = "Test"
  	assert email.save, "Adding subject did not save the email."
  end

  test "can't save eail without recipient" do
  	email = KidsEmail.new
  	email.subject = "Test"
  	email.html_body = "<b>Hello</b>"
  	email.text_body = "Hello"
  	email.franchise_id = 1
  	assert !email.save, "Email saved without a recipient"
  	email.recipients = "everyone"
  	assert email.save, "Adding recipient did not save the email."
  end

  test "can't save eail without html body" do
  	email = KidsEmail.new
  	email.subject = "Test"
  	email.recipients = "everyone"
  	email.text_body = "Hello"
  	email.franchise_id = 1
  	assert !email.save, "Email saved without an html body"
  	email.html_body = "<b>Hello</b>"
  	assert email.save, "Adding html body did not save the email."
  end

  test "valid email saves" do 
  	email = KidsEmail.new
  	email.subject = "Test"
  	email.recipients = "everyone"
  	email.franchise_id = 1
  	email.html_body = "<b>Hello</b>"
  	assert email.save, "Email did not save."
  end

  test "franchise email won't save without franchise" do
  	email = KidsEmail.new
  	email.subject = "Test"
  	email.recipients = "everyone"
  	email.text_body = "Hello"
  	email.html_body = "<b>Hello</b>"
  	assert !email.save, "Email saved without a franchise"
  	email.franchise_id = 1
  	assert email.save, "Adding franchise did not save the email."
  end

  test "valid master email saves without franchise" do 
  	email = KidsEmail.new
  	email.subject = "Test"
  	email.recipients = "everyone"
  	email.html_body = "<b>Hello</b>"
  	email.master_email = true
  	assert email.save, "Email did not save."
  end

  test "master email has 9 recipient options" do
  	email = KidsEmail.new
  	email.master_email = true
  	assert_equal email.recipients_array.length, 9
  end

  test "franchise email has 9 recipient options" do
  	email = KidsEmail.new
  	assert_equal email.recipients_array.length, 8
  end

  test "franchise email for franchise 1 to consignors produces 5 emails" do
  	email = KidsEmail.new
  	email.franchise_id = 1
  	email.recipients = "consignors"
  	assert_equal email.number_of_emails, 4
  end

  test "franchise email for franchise 1 to volunteers produces 4 emails" do
  	email = KidsEmail.new
  	email.franchise_id = 1
  	email.recipients = "volunteers"
  	assert_equal email.number_of_emails, 4
  end

  test "master email to consignors produces 5 emails" do
  	email = KidsEmail.new
  	email.master_email = true
  	email.recipients = "consignors"
  	assert_equal email.number_of_emails, 4
  end

  test "master email to volunteers produces 4 emails" do
  	email = KidsEmail.new
  	email.master_email = true
  	email.recipients = "consignors"
  	assert_equal email.number_of_emails, 4
  end

  test "franchise email for franchise 1 to rewards produces 1 email" do
  	email = KidsEmail.new
  	email.franchise_id = 1
  	email.recipients = "rewards"
  	assert_equal email.number_of_emails, 0
  end

  test "master email to rewards produces 2 emails" do
  	email = KidsEmail.new
  	email.master_email = true
  	email.recipients = "rewards"
  	assert_equal email.number_of_emails, 2
  end

  test "franchise email for franchise 1 to everyone produces 6 emails" do
  	email = KidsEmail.new
  	email.franchise_id = 1
  	email.recipients = "everyone"
  	assert_equal email.number_of_emails, 9
  end

  test "master email to everyone produces 8 emails" do
  	email = KidsEmail.new
  	email.master_email = true
  	email.recipients = "everyone"
  	assert_equal email.number_of_emails, 59
  end
end
