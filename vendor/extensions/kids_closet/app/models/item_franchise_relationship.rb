class ItemFranchiseRelationship < ActiveRecord::Base
	belongs_to :consignor_inventory
	belongs_to :franchise

	validates_uniqueness_of :consignor_inventory_id, :scope => :franchise_id

	def self.clean_up_table
		array_to_delete = []
		for franchise_number in Franchise.franchises_with_online_sales
			array = []
			for item in Franchise.find(franchise_number).item_franchise_relationships.find(:all)
				if array.include?(item.consignor_inventory_id)
					array_to_delete << item.id
				else
					array << item.consignor_inventory_id
				end
			end
		end
		for item in array_to_delete
			find(item).destroy
		end
	end
end
