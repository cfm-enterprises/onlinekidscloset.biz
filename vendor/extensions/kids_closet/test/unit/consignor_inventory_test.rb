require File.dirname(__FILE__) + '/../test_helper'

class ConsignorInventoryTest < ActiveSupport::TestCase
  # Replace this with your real tests.

  fixtures :consignor_inventories, :profiles

  test "check fixtures loaded 750 items" do
    assert_equal 750, ConsignorInventory.count
  end
  
  test "number of archivable items" do
    assert_equal 100, ConsignorInventory.items_to_archive.count
  end
  
  test "archiving items deletes 100 items exactly" do
    ConsignorInventory.archive_items
    assert_equal 650, ConsignorInventory.count
  end

  test "item has a valid profile" do
    item = ConsignorInventory.new
    item.price = 1
    item.quantity = 1
    item.item_description = "New Item"
    item.size = 1
    assert !item.save, "item saved without a profile"
    item.profile = profiles(:consignor_1)
    assert item.save, "adding the profile did NOT save the item"
  end

  test "item has a valid price" do
    item = ConsignorInventory.new
    item.profile = profiles(:consignor_1)
    item.quantity = 1
    item.item_description = "New Item"
    item.size = 1
    assert !item.save, "item saved without a price"
    item.price = 1
    assert item.save, "adding the price did NOT save the item"
  end

  test "item has a valid numeric price" do
    item = ConsignorInventory.new
    item.profile = profiles(:consignor_1)
    item.quantity = 1
    item.price = "abc"
    item.item_description = "New Item"
    item.size = 1
    assert !item.save, "item saved with non numeric price"
    item.price = 1
    assert item.save, "fixing the price did NOT save the item"
  end
  
  test "item has a valid integer price" do
    item = ConsignorInventory.new
    item.profile = profiles(:consignor_1)
    item.quantity = 1
    item.price = 1.25
    item.item_description = "New Item"
    item.size = 1
    assert !item.save, "item saved with decimal price"
    item.price = 1
    assert item.save, "fixing the price did NOT save the item"
  end

  test "item saves with a 50 cent increment price" do
    item = ConsignorInventory.new
    item.profile = profiles(:consignor_1)
    item.quantity = 1
    item.price = 1.5
    item.item_description = "New Item"
    item.size = 1
    assert item.save, "item did not save with a fifty cent increment"
  end

  test "item has a valid greater than 0 price" do
    item = ConsignorInventory.new
    item.profile = profiles(:consignor_1)
    item.quantity = 1
    item.price = 0
    item.item_description = "New Item"
    item.size = 1
    assert !item.save, "item saved with zero price"
    item.price = 1
    assert item.save, "fixing the price did NOT save the item"
  end

  test "item has a valid greater than $0.50 price" do
    item = ConsignorInventory.new
    item.profile = profiles(:consignor_1)
    item.quantity = 1
    item.price = 0.50
    item.item_description = "New Item"
    item.size = 1
    assert !item.save, "item saved with fifty cent price"
    item.price = 1
    assert item.save, "fixing the price did NOT save the item"
  end

  test "item has a valid positive price" do
    item = ConsignorInventory.new
    item.profile = profiles(:consignor_1)
    item.quantity = 1
    item.price = -4
    item.item_description = "New Item"
    item.size = 1
    assert !item.save, "item saved with negative price"
    item.price = 1
    assert item.save, "fixing the price did NOT save the item"
  end
  
  test "item has a description no longer than 40 characters" do
    item = ConsignorInventory.new
    item.profile = profiles(:consignor_1)
    item.quantity = 1
    item.price = 1
    item.item_description = "12345678901234567890123456789012345678901"
    item.size = 1
    assert !item.save, "item saved with too long a description"
    item.item_description = "New Item"
    assert item.save, "fixing the price did NOT save the item"
  end
  
  test "item has a valid quantity" do
    item = ConsignorInventory.new
    item.profile = profiles(:consignor_1)
    item.price = 1
    item.quantity = "abc"
    item.item_description = "New Item"
    item.size = 1
    assert !item.save, "item saved with non numeric quantity"
    item.quantity = 1
    assert item.save, "fixing the quantity did NOT save the item"
  end
  
  test "item has a valid quantity lower than 100" do
    item = ConsignorInventory.new
    item.profile = profiles(:consignor_1)
    item.quantity = 101
    item.price = 1
    item.item_description = "New Item"
    item.size = 1
    assert !item.save, "item saved with quantity greater than 100"
    item.quantity = 1
    assert item.save, "fixing the quantity did NOT save the item"
  end

  test "item has a valid greater than 0 quantity" do
    item = ConsignorInventory.new
    item.profile = profiles(:consignor_1)
    item.price = 1
    item.quantity = 0
    item.item_description = "New Item"
    item.size = 1
    assert !item.save, "item saved with zero quantity"
    item.quantity = 1
    assert item.save, "fixing the quantity did NOT save the item"
  end

  test "item has a valid positive quantity" do
    item = ConsignorInventory.new
    item.profile = profiles(:consignor_1)
    item.price = 1
    item.quantity = -4
    item.item_description = "New Item"
    item.size = 1
    assert !item.save, "item saved with negative quantity"
    item.quantity = 1
    assert item.save, "fixing the quantity did NOT save the item"
  end

  test "item can't have size greater than 15 characters" do
    item = ConsignorInventory.new
    item.profile = profiles(:consignor_1)
    item.price = 1
    item.quantity = 1
    item.item_description = "New Item"
    item.size = "1234567890123456"
    assert !item.save, "item saved with invalid size"
    item.size = 1
    assert item.save, "fixing the size did NOT save the item"
  end

  test "valid item saves" do
    item = ConsignorInventory.new
    item.profile = profiles(:consignor_1)
    item.price = 1
    item.quantity = 1
    item.item_description = "New Item"
    item.size = 1
    assert item.save, "valid item did not save"
  end
    
  test "can't edit the size of an item" do
    item = ConsignorInventory.new
    item.profile = profiles(:consignor_1)
    item.price = 1
    item.quantity = 1
    item.item_description = "New Item"
    item.size = 1
    assert item.save, "valid item did not save"
    item.size = "1234567890123456"
    assert !item.save, "item edited to invalid size"
  end
    
  test "should be able to save an item with a pre-existing invalid size" do
    item = ConsignorInventory.find(151)
    assert item.save
  end
    
  test "valid item qith quantity 11 saves and adds 11 to total inventory" do
    item = ConsignorInventory.new
    item.profile = profiles(:consignor_1)
    item.price = 1
    item.quantity = 11
    item.item_description = "New Item"
    item.size = 1
    item.save
    assert_equal 761, ConsignorInventory.count
  end
    
  test "valid item saves and adds one to total inventory" do
    item = ConsignorInventory.new
    item.profile = profiles(:consignor_1)
    item.price = 1
    item.quantity = 1
    item.item_description = "New Item"
    item.size = 1
    item.save
    assert_equal 751, ConsignorInventory.count
  end

end
