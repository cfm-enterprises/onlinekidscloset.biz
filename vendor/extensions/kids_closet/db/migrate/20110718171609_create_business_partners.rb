class CreateBusinessPartners < ActiveRecord::Migration
  def self.up
    create_table :business_partners do |t|
      t.integer :site_id, :sale_id, :sort_index
      t.string :partner_url, :partner_title
      t.text :partner_description
      t.timestamps
    end
  end

  def self.down
    drop_table :business_partners
  end
end
