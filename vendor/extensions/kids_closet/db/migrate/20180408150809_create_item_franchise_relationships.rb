class CreateItemFranchiseRelationships < ActiveRecord::Migration
  def self.up
    create_table :item_franchise_relationships do |t|
    	t.integer :franchise_id, :consignor_inventory_id
      t.timestamps
    end
  end

  def self.down
    drop_table :item_franchise_relationships
  end
end
