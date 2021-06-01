require 'ftools'
class ConsignorInventory < ActiveRecord::Base
  require 'barby'
  require 'barby/outputter/png_outputter'

  attr_accessible :price, :item_description, :size, :featured_item, :last_day_discount, :quantity, :donate, :additional_information, :category, :sub_category

  belongs_to :profile
  belongs_to :sale
  belongs_to :transaction_import
  belongs_to :rewards_profile
  has_one :order
  has_many :featured_photos, :dependent => :destroy
  has_many :item_franchise_relationships, :dependent => :destroy
    
  acts_as_site_member

  attr_accessor :quantity, :has_valid_photo

  validates_presence_of :profile_id, :message => " must be a valid consignor number"
  validates_presence_of :price
  validates_numericality_of :price, :greater_than_or_equal_to => 1, :message => " must be a valid dollar amount greater or equal to $1.00"
  validates_numericality_of :price, :greater_than_or_equal_to => 5, :message => " must be a valid dollar amount greater or equal to $5.00 for items sold online", :if => :featured_item
  validates_length_of :item_description, :maximum  => 40, :message => " must be smaller than 40 characters"
  validates_length_of :size, :maximum => 20, :message => " must be smaller than 20 characters", :if => :validate_size
  
  before_destroy :delete_site_assets
  after_create :create_site_asset
  after_create :create_duplicate_items
#  after_update :delete_featured_photos_if_not_featured
  after_save :add_or_remove_from_franchise_sale_list
  named_scope :donated_items, :conditions => "donate_date IS NOT NULL"

  def validate
    errors.add(:sale_date, "must fall between or near the sale dates of the sale") if !sale_date.nil? && !sold_online && !sale.nil? && (sale_date < sale.start_date - 2 || sale_date > sale.end_date + 5) && sale.tentative_date.blank?
    unless quantity.nil?
      errors.add(:quantity, "must fall between 1 and 100") if quantity.to_i <= 0 || quantity.to_i > 100
    end
    errors.add(:featured_item, " - items sold online must have at least one photo attached") if new_record? && featured_item && has_valid_photo != 1
    begin
      errors.add(:price, "must be in fifty cent increments") unless price == 0 || (price * 2 / (price * 2).to_i) == 1
    rescue

    end
    errors.add(:quantity, "must be one for items sold online") if new_record? && featured_item && !quantity.nil? && quantity.to_i > 1
    errors.add(:category, "must be selected for items sold online") if featured_item && status = 0 && category.nil?
    unless ConsignorInventory.sub_category_array(self.category_name).empty?
      errors.add(:sub_category, "must be selected for items sold online in the selected category") if featured_item && !status && sub_category.empty_or_nil?
    end
    unless ConsignorInventory.size_array(self.category_name).empty?
      errors.add(:size, "must be selected for items sold online in the selected category") if featured_item && !status && size.empty_or_nil?
    end
  end

  def barcode_file_path
    return "#{RAILS_ROOT}/public/assets/1/barcode_#{self.id}.png"
  end

  def has_featured_photo?
    !main_photo.nil?
  end

  def main_photo
    featured_photos.find(:first)
  end

  def category_name
    case category
    when "1"
        "Boy's Clothing"
    when "2"
        "Girl's Clothing"
    when "3"
        "Maternity Clothing"
    when "4"
        "Boy's Shoes"
    when "5"
        "Girl's Shoes"
    when "6"
        "Boys Accessories"
    when "7"
        "Girls Accessories"
    when "8"
        "Baby, Toddler & Preschool Toys"
    when "9"
        "Youth (Girls and Boys) Toys"
    when "10"
        "Games & Puzzles"
    when "11"
        "Books"
    when "12"
        "Backpacks, Lunchboxes & Purses"
    when "13"
        "Sporting Gear and Pool Supplies"
    when "14"
        "Sport Clothing"
    when "15"
        "Sporting Shoes"
    when "16"
        "Baby Items"
    when "17"
        "Baby Clothing Accessories"
    when "18"
        "Bedding & Room Decor"
    when "19"
        "Halloween Costumes"
    when "20"
        "No Category"
    when "22"
        "Handmade and Boutique Items"
    when "23"
        "DVDs, Video Games & Electronics"
    when "24"
        "Baby Furniture"
    when "25"
        "Baby Gear & Equipment"
    when "26"
        "Mommy Corner"
    when "27"
        "Home School/Classroom Supplies"
    when "28"
        "Party Supplies and Seasonal Accessories"
    when "29"
        "Mommy Corner Clothing"
    else
        "No Category"
    end
  end

  class << self
    def per_page
      15
    end

    def quick_search(conditions, page)
      paginate(:all, :page => page,
          :conditions => conditions,
          :order => 'sale_date, item_description, size, price DESC')
    end
    
    def build_quick_conditions(sale_id, item_id, item_name, profile_id, transaction_date, import_id, transaction_number, consignor_search)
      conditions = []
      conditions << ["status = ?", true]
      conditions << ["sale_id = ?", sale_id.to_i]
      conditions << ["id = ?", item_id.to_i] unless item_id.nil? || item_id.blank?
      conditions << ["item_description LIKE lower(?)", "%#{item_name}%"] unless item_name.blank? || item_name.nil?
      conditions << ["profile_id = ?", profile_id.to_i] unless profile_id.blank? || profile_id.nil?
      conditions << ["sale_date = ?", transaction_date] unless transaction_date.blank? || transaction_date.nil?
      conditions << ["transaction_import_id = ?", import_id.to_i] unless import_id.blank? || import_id.nil?
      conditions << ["transaction_number = ?", transaction_number.to_i] unless transaction_number.blank? || transaction_number.nil?
      conditions << ["profile_id = ?", consignor_search.to_i] unless consignor_search.blank? || consignor_search.nil?
      conditions_string = [conditions.map{|condition| condition[0]}.join(" AND ")]
      conditions_array = conditions.map{|condition| condition[1]}
      conditions = conditions_string + conditions_array
    end

    def build_items_coming_quick_conditions(item_id, item_name, size, featured_only, category_id)
      return nil if (item_id.nil? || item_id.blank?) && (item_name.nil? || item_name.blank?) && (size.nil? || size.blank?) && !featured_only && (category_id.nil? || category_id.blank?)
      conditions = []
      conditions << ["id = ?", item_id.to_i] unless item_id.nil? || item_id.blank?
      conditions << ["size LIKE lower(?)", "%#{self.escape_javascript(size)}%"] unless size.blank? || size.nil?
      conditions << ["item_description LIKE lower(?)", "%#{item_name}%"] unless item_name.blank? || item_name.nil?
      conditions << ["featured_item = ?", true] if featured_only
      conditions << ["category = ?", category_id.to_i] unless category_id.nil? || category_id.blank?
      conditions_string = [conditions.map{|condition| condition[0]}.join(" AND ")]
      conditions_array = conditions.map{|condition| condition[1]}
      conditions = conditions_string + conditions_array
    end

    def amount_sold_for_conditions(conditions)
      sum(:sale_price, :conditions => conditions)
    end
    
    def tax_collected_for_conditions(conditions)
      sum(:tax_collected, :conditions => conditions)
    end
    
    def form_for_find(id, profile_id)
      ConsignorInventory.find(:first, :conditions => ["id = ? AND profile_id = ?", id, profile_id])
    end

    def create_barcode(item)    
      barcode_string = ConsignorInventory.get_barcode(item)
      barcode = Barby::Code128.new(barcode_string, 'A')
      file_path = item.barcode_file_path
      File.open(file_path, "w") { |f| f.write barcode.to_png(:height => 23, :margin => 2) }
    end
    
    def get_barcode(item)
      return "#{item.profile_id}#{13.chr}#{item.id}#{13.chr}#{item.price}#{13.chr}#{item.last_day_discount ? 50 : 0}#{13.chr}"
    end
    
    def items_to_archive
      find(:all, :conditions => ["created_at < ? AND status = ? AND donate_date IS NULL", Time.now - 60 * 60 * 24 * 30.5 * 29, false])
    end
    
    def archive_items
      for item in ConsignorInventory.items_to_archive
        item.destroy
      end
    end

    def voice_converstion(voice_entry)
      inventory = new
      description_marker = voice_entry.downcase.index('description')
      has_description_marker = !description_marker.nil?
      description_start = has_description_marker ? description_marker + 12 : 0
      size_marker = voice_entry.downcase.index('size')
      has_size_marker = !size_marker.nil?
      if has_size_marker
        description_end = size_marker - 2
        size_start = size_marker + 5
      else
        size_start = 0
      end
      fisher_price_marker = voice_entry.downcase.index('fisher price')
      has_fisher_price_marker = !fisher_price_marker.nil?
      if has_fisher_price_marker
        price_marker = voice_entry[fisher_price_marker + 12..voice_entry.size].downcase.index('price') +  12 + fisher_price_marker
      else
        price_marker = voice_entry.downcase.index('price')
      end
      has_price_marker = !price_marker.nil?
      if has_price_marker
        description_end = price_marker - 2 unless has_size_marker
        size_end = price_marker - 2
        price_start = price_marker + 6
      else
        price_start = 0
      end
      quantity_marker = voice_entry.downcase.index('quantity')
      has_quantity_marker = !quantity_marker.nil?
      if has_quantity_marker
        description_end = quantity_marker - 2 unless has_size_marker || has_price_marker
        size_end = quantity_marker - 2 unless has_price_marker
        price_end = quantity_marker - 2
        quantity_start = quantity_marker + 9
      else
        quantity_marker = voice_entry.downcase.index('qty')
        has_quantity_marker = !quantity_marker.nil?
        if has_quantity_marker
          description_end = quantity_marker - 2 unless has_size_marker || has_price_marker
          size_end = quantity_marker - 2 unless has_price_marker
          price_end = quantity_marker - 2
          quantity_start = quantity_marker + 4
        else
          quantity_marker = voice_entry.downcase.index('qty.')
          has_quantity_marker = !quantity_marker.nil?
          if has_quantity_marker
            description_end = quantity_marker - 2 unless has_size_marker || has_price_marker
            size_end = quantity_marker - 2 unless has_price_marker
            price_end = quantity_marker - 2
            quantity_start = quantity_marker + 5
          else
            quantity_start = 0
          end
        end
      end
      discount_marker = voice_entry.downcase.index('discount')
      has_discount_marker = !discount_marker.nil?
      if has_discount_marker
        description_end = discount_marker - 2 unless has_size_marker || has_price_marker || has_quantity_marker
        size_end = discount_marker - 2 unless has_price_marker || has_quantity_marker
        price_end = discount_marker - 2 unless has_quantity_marker
        quantity_end = discount_marker - 2
        discount_start = discount_marker + 9
      else
        discount_start = 0
      end
      donate_marker  = voice_entry.downcase.index('donate')
      has_donate_marker = !donate_marker.nil?
      if has_donate_marker
        description_end = donate_marker - 2 unless has_size_marker || has_price_marker || has_quantity_marker || has_discount_marker
        size_end = donate_marker - 2 unless has_price_marker || has_quantity_marker || has_discount_marker
        price_end = donate_marker - 2 unless has_quantity_marker || has_discount_marker
        quantity_end = donate_marker - 2 unless has_discount_marker
        discount_end = donate_marker - 2
        donate_start = donate_marker + 7
      else
        donate_start = 0
      end
      add_marker = voice_entry.downcase.index('add')
      unless add_marker.nil?
        description_end = add_marker - 2 unless has_size_marker || has_price_marker || has_quantity_marker || has_discount_marker || has_donate_marker
        size_end = add_marker - 2 unless has_price_marker || has_quantity_marker || has_discount_marker || has_donate_marker
        price_end = add_marker - 2 unless has_quantity_marker || has_discount_marker || has_donate_marker
        quantity_end = add_marker - 2 unless has_discount_marker || has_donate_marker
        discount_end = add_marker - 2 unless has_donate_marker
        donate_end = add_marker - 2 if has_donate_marker
      else
        description_end = voice_entry.length unless has_size_marker || has_price_marker || has_quantity_marker || has_discount_marker || has_donate_marker
        size_end = voice_entry.length unless has_price_marker || has_quantity_marker || has_discount_marker || has_donate_marker
        price_end = voice_entry.length unless has_quantity_marker || has_discount_marker || has_donate_marker
        quantity_end = voice_entry.length unless has_discount_marker || has_donate_marker
        discount_end = voice_entry.length unless has_donate_marker
        donate_end = voice_entry.length if has_donate_marker
      end
      loaded_description = voice_entry[description_start..description_end]
      inventory.item_description = replace_description_string(loaded_description)
      loaded_size = voice_entry[size_start..size_end] if has_size_marker
      inventory.size = replace_size_string(loaded_size) if has_size_marker
      loaded_price = voice_entry[price_start..price_end] if has_price_marker
      inventory.price = replace_string_digits(loaded_price) if has_price_marker
      if has_quantity_marker
        loaded_quantity = voice_entry[quantity_start..quantity_end]
        inventory.quantity = replace_string_digits(loaded_quantity)
      else
        loaded_quantity = 1
      end
      loaded_discount = voice_entry[discount_start..discount_end] if has_discount_marker
      loaded_discount = "yes" if loaded_discount.nil?
      inventory.last_day_discount =  has_discount_marker &&  loaded_discount.downcase == "no" ? false : true
      loaded_donate = voice_entry[donate_start..donate_end] if has_donate_marker
      inventory.donate = has_donate_marker && !loaded_donate.nil? && loaded_donate.downcase == "yes" ? true : false
      return inventory
    end

    def replace_description_string(string)
      string = string.to_s.downcase
      string.gsub!("tommy hill figure", "Tommy Hilfiger")
      string.gsub!("grayco", "Graco")
      string.gsub!("kraco", "Graco")
      string.gsub!("jagging's", "jeggings")
      string = string.titleize
    end

    def replace_string_digits(string)
      string = string.to_s.downcase
      string.gsub!("ten", "10")
      string.gsub!("eleven", "11")
      string.gsub!("twelve", "12")
      string.gsub!("thirteen", "13")
      string.gsub!("fourteen", "14")
      string.gsub!("fifteen", "15")
      string.gsub!("sixteen", "16")
      string.gsub!("seventeen", "17")
      string.gsub!("eighteen", "18")
      string.gsub!("nineteen", "19")
      string.gsub!("twenty ", "20")
      string.gsub!("thirty ", "30")
      string.gsub!("fourty ", "40")
      string.gsub!("fifty ", "50")
      string.gsub!("sixty ", "60")
      string.gsub!("seventy ", "70")
      string.gsub!("eighty ", "80")
      string.gsub!("ninety ", "90")
      string.gsub!("twenty", "2")
      string.gsub!("thirty", "3")
      string.gsub!("fourty", "4")
      string.gsub!("fifty", "5")
      string.gsub!("sixty", "6")
      string.gsub!("seventy", "7")
      string.gsub!("eighty", "8")
      string.gsub!("ninety", "9")
      string.gsub!("one", "1")
      string.gsub!("two", "2")
      string.gsub!("three", "3")
      string.gsub!("four", "4")
      string.gsub!("five", "5")
      string.gsub!("six", "6")
      string.gsub!("seven", "7")
      string.gsub!("eight", "8")
      string.gsub!("nine", "9")
      string.gsub!("for", "4")
      string.gsub!("too", "2")
      string.gsub!("to", "2")
      string.gsub!("and", ".")
      string.slice! "$"
      string.slice! "dollars"
      string.slice! "dollar"
      string.slice! "cents"
      string.slice! "cent"
      string.slice! "-"
      string.gsub!(" ", "")
      string.to_f
    end

    def replace_size_string(string)
      string = string.downcase
      string.gsub!("ten", "10")
      string.gsub!("eleven", "11")
      string.gsub!("twelve", "12")
      string.gsub!("thirteen", "13")
      string.gsub!("fourteen", "14")
      string.gsub!("fifteen", "15")
      string.gsub!("sixteen", "16")
      string.gsub!("seventeen", "17")
      string.gsub!("eighteen", "18")
      string.gsub!("nineteen", "19")
      string.gsub!("one", "1")
      string.gsub!("two", "2")
      string.gsub!("three", "3")
      string.gsub!("four", "4")
      string.gsub!("five", "5")
      string.gsub!("six", "6")
      string.gsub!("seven", "7")
      string.gsub!("eight", "8")
      string.gsub!("nine", "9")
      string.gsub!(" to ", "-")
      string.gsub!("too", "2")
      string.gsub!("to", "2")
      string.gsub!(" tee", "T")
      string.gsub!(" tea", "T")
      string.gsub!("tee", "T")
      string.gsub!("tea", "T")
      string.gsub!("for", "4")
      string.gsub(" dash ", "-")
      string.gsub("dash", "-")
      string = string.capitalize
      string.gsub("Xll", "XLL")
      string.gsub("Xl", "XL")
      string.gsub("Xss", "XSS")
      string.gsub("Xs", "XS")
      string.gsub("X", "X")
    end

    def rename_featured_file(item_id)
      item = ConsignorInventory.find(item_id)
      old_file_name = item.asset_file_name
      unless old_file_name.nil? || old_file_name[0, 9] == "featured_"
        extension_begins_at = old_file_name.index('.', -7)
        old_file_path = "#{RAILS_ROOT}/public/assets/#{item.site_id}/original/#{old_file_name}"
        old_thumb_path = "#{RAILS_ROOT}/public/assets/#{item.site_id}/thumb/#{old_file_name}"
        old_featured_path = "#{RAILS_ROOT}/public/assets/#{item.site_id}/featured/#{old_file_name}"
        new_file_name = "featured_#{item.id}#{old_file_name[extension_begins_at, 10]}"
        new_file_path = "#{RAILS_ROOT}/public/assets/#{item.site_id}/original/#{new_file_name}"
        new_thumb_path = "#{RAILS_ROOT}/public/assets/#{item.site_id}/thumb/#{new_file_name}"
        new_featured_path = "#{RAILS_ROOT}/public/assets/#{item.site_id}/featured/#{new_file_name}"
        if File.exists?(old_file_path)
          File.move(old_file_path, new_file_path)
        end
        if File.exists?(old_thumb_path)
          File.move(old_thumb_path, new_thumb_path)
        end
        if File.exists?(old_featured_path)
          File.move(old_featured_path, new_featured_path)
        end
        item.asset_file_name = new_file_name
        item.save_with_validation(false)
      end
    end

    def featured_items_fix
      items = ConsignorInventory.find(:all, :conditions => ["featured_item = ? AND asset_file_name IS NOT NULL", true])
      for item in items
        unless item.asset_file_name.blank?
          photo = FeaturedPhoto.new
          photo.consignor_inventory_id = item.id
          photo.display_name = item.display_name
          photo.asset_file_name = item.asset_file_name
          photo.asset_content_type = item.asset_content_type
          photo.asset_file_size = item.asset_file_size
          photo.save
          item.display_name = nil
          item.asset_file_name = nil
          item.asset_content_type = nil
          item.asset_file_size = nil
          item.save
        end
      end
    end
  
    def category_array
      [["Boy's Clothing","1"],
      ["Girl's Clothing","2"],
      ["Maternity Clothing","3"],
      ["Boy's Shoes","4"],
      ["Girl's Shoes","5"],
      ["Boys Accessories","6"],
      ["Girls Accessories","7"],
      ["Baby, Toddler & Preschool Toys","8"],
      ["Youth (Girls and Boys) Toys","9"],
      ["Handmade and Boutique Items", "22"],
      ["Games & Puzzles","10"],
      ["Books","11"],
      ["DVDs, Video Games & Electronics", "23"],
      ["Backpacks, Lunchboxes & Purses","12"],
      ["Sporting Gear and Pool Supplies","13"],
      ["Sport Clothing","14"],
      ["Sporting Shoes","15"],
      ["Baby Items","16"],
      ["Baby Furniture","24"],
      ["Baby Gear & Equipment","25"],
      ["Baby Clothing Accessories","17"],
      ["Bedding & Room Decor","18"],
      ["Halloween Costumes","19"],
      ["Party Supplies and Seasonal Accessories", "28"],
      ["Mommy Corner Clothing", "29"],
      ["Mommy Corner", "26"],
      ["Home School/Classroom Supplies", "27"]]
    end

    def sub_category_array(category_name)
      case category_name
      when "Boy's Clothing"
        ["Onesies",
        "Outfits",
        "Pants/Jeans",
        "Tops/Shirts",
        "Pajamas",
        "Shorts",
        "Swimwear",
        "Jacket",
        "Special Occasion/Holiday"]
      when "Girl's Clothing"
        ["Onesies",
        "Outfits",
        "Pants/Jeans",
        "Tops/Shirts",
        "Shorts/Skirts",
        "Dresses",
        "Pajamas",
        "Swimwear",
        "Jacket",
        "Special Occasion/Holiday"]
      when "Maternity Clothing"
        ["Accessories",
        "Outfits",
        "Tops/Shirts",
        "Pants/Jeans",
        "Shorts/Skirts",
        "Dresses",
        "Pajamas",
        "Swimwear",
        "Special Occasion/Holiday"]
      when "Boys Accessories"
        ["Belts",
        "Hats",
        "Scarves, Mittens & Gloves",
        "Socks",
        "Underwear",
        "Other"]
      when "Girls Accessories"
        ["Belts, Jewelry & Hair",
        "Gloves, Scarves & Mittens",
        "Hair Accessories",
        "Hats",
        "Socks",
        "Tights",
        "Undergarments",
        "Other"]
      when "Baby, Toddler & Preschool Toys"
        ["Arts & Crafts",
        "Bath Toys",
        "Blocks, Stacking & Sorting Toys",
        "Cars, Trucks & Trains",
        "Crib Toys",
        "Dolls & Dollhouses",
        "Dress Up & Pretend Play",
        "Gyms & Playmats",
        "Learning Toys (V-Tech, etc)",
        "Legos/Mega Blocks",
        "Little People",
        "Melissa and Doug",
        "Musical Toys & Instruments",
        "Outdoor Play Toys",
        "Pool & Water Toys",
        "Rattles & Teethers",
        "Stuffed Animals",
        "Trikes, Riding & Push Toys",
        "Other"]
      when "Youth (Girls and Boys) Toys"
        ["Action Figures & Dinosaurs",
        "Arts & Crafts",
        "Bikes and Riding Toys",
        "Building Sets and Blocks",
        "Cars, Trucks & Trains",
        "Dolls, Dollhouses & Accessories",
        "Dress Up & Pretend Play",
        "Electronics",
        "Learning Toys",
        "Legos",
        "Melissa and Doug",
        "Musical Toys & Instruments",
        "Outdoor Toys",
        "Playsets",
        "Pool & Water Toys",
        "Racetracks & Play Mats",
        "Science & Tech Toys",
        "Stuffed Animals",
        "Other"]
      when "Games & Puzzles"
        ["Board Game",
        "Electronic Game",
        "Jigsaw Puzzle",
        "Wooden Puzzle",
        "Other"]
      when "Books"
        ["Activity Books & Pads",
        "Baby Books",
        "Board Books",
        "Chapter Books",
        "Disney Books",
        "Easy Reader Books",
        "Educational Books",
        "Holiday Books",
        "Mommy Books",
        "Picture Books",
        "Religious Books",
        "Other"]
      when "DVDs, Video Games & Electronics"
        ["DVD's",
          "Video Games",
          "Electronics"]
      when "Backpacks, Lunchboxes & Purses"
        ["Backpacks",
        "Lunch Boxes",
        "Purses",
        "Other"]
      when "Sporting Gear and Pool Supplies"
        ["Baseball/Softball",
        "Basketball",
        "Dance/Cheer",
        "Football",
        "Golf",
        "Hockey/Skating",
        "Pool Supplies",
        "Soccer",
        "Tennis",
        "Volleyball",
        "Other"]
      when "Sport Clothing"
        ["Baseball/Softball",
        "Basketball",
        "Dance/Cheer",
        "Football",
        "Golf",
        "Hockey/Skating",
        "Soccer",
        "Tennis",
        "Volleyball",
        "Other"]
      when "Sporting Shoes"
        ["Baseball/Softball",
        "Basketball",
        "Dance/Cheer",
        "Football",
        "Golf",
        "Hockey/Skating",
        "Soccer",
        "Tennis",
        "Volleyball",
        "Other"]
      when "Baby Items"
        ["Baby Seats",
        "Baby Bath",
        "Car Seats/Shopping Cart Covers",
        "Crib Sheets & Mattress Covers",
        "Diapers, Diaper Bags, Diaper Covers",
        "Feeding Supplies",
        "Health & Safety",
        "Nursing Items",
        "Potty's",
        "Slings & Baby Carriers",
        "Swaddles, Blankets & Lovies",
        "Other"]
      when "Baby Furniture"
        ["Bassinets",
          "Bedroom Sets",
          "Cribs",
          "Changing Tables",
          "Rockers & Gliders",
          "Toddler Beds",
          "Other"]
      when "Baby Gear & Equipment"
          ["Car Seats",
            "Gates & Play Yards",
            "High Chairs & Boosters",
            "Stroller & Accessories",
            "Swings",
            "Travel Systems & Pack N Plays",
            "Walkers, Jumpers, and Bouncers",
            "Other"]
      when "Baby Clothing Accessories"
        ["Baby Socks",
        "Baby Hats",
        "One-sies",
        "Other"]
      when "Bedding & Room Decor"
        ["Chairs",
        "Crib Bedding & Accessories",
        "Room Decor",
        "Sheets",
        "Sleeping Bags & Pillows",
        "Youth Bedding"]
      when "Mommy Corner"
        [ "Home",
          "Kitchen",
          "Crafts",
          "Purses & Acc",
          "Wedding Acc",
          "Books",
          "Seasonal"]
      else
        []
      end
    end

    def size_array(category_name, current_size = nil)
      case category_name
      when "Boy's Clothing"
        rvalue = ["Preemie",
        "Newborn",
        "Boys 3 months",
        "Boys 6 months",
        "Boys 9 months",
        "Boys 12 months",
        "Boys 18 months",
        "Boys 24 months",
        "Boys 2T",
        "Boys 3T",
        "Boys 4T",
        "Boys 5T",
        "Boys 6-6X",
        "Boys 7",
        "Boys 8",
        "Boys 10",
        "Boys 12",
        "Boys 14",
        "Boys 16",
        "Boys 18",
        "Boys 20",
        "Men's Small",
        "Men's Medium",
        "Men's Large",
        "Men's X Large"]
      when "Girl's Clothing"
        rvalue = ["Newborn",
        "Girls 3 months",
        "Girls 6 months",
        "Girls 9 months",
        "Girls 12 months",
        "Girls 18 months",
        "Girls 24 months",
        "Girls 2T",
        "Girls 3T",
        "Girls 4T",
        "Girls 5T",
        "Girls 6-6X",
        "Girls 7",
        "Girls 8",
        "Girls 10",
        "Girls 12",
        "Girls 14",
        "Girls 16",
        "Girls 18",
        "Junior X-Small",
        "Junior Small",
        "Junior Medium",
        "Junior Large"]
      when "Maternity Clothing"
        rvalue = ["Small",
        "Medium",
        "Large",
        "X-Large"]
      when "Boy's Shoes"
        rvalue = ["Infant 0",
        "Infant 1",
        "Infant 2",
        "Infant 3",
        "Infant 4",
        "Infant 5",
        "Infant 6",
        "Infant 7",
        "Little Boys 8",
        "Little Boys 9",
        "Little Boys 10",
        "Little Boys 11",
        "Little Boys 12",
        "Little Boys 13",
        "Big Boys 1",
        "Big Boys 2",
        "Big Boys 3",
        "Big Boys 4",
        "Big Boys 5",
        "Big Boys 6",
        "Big Boys 7",
        "Men's 8",
        "Men's 9",
        "Men's 10",
        "Men's 11",
        "Men's 12",
        "Men's 13"]
      when "Girl's Shoes"
        rvalue = ["Infant 0",
        "Infant 1",
        "Infant 2",
        "Infant 3",
        "Infant 4",
        "Infant 5",
        "Infant 6",
        "Infant 7",
        "Little Girls 8",
        "Little Girls 9",
        "Little Girls 10",
        "Little Girls 11",
        "Little Girls 12",
        "Little Girls 13",
        "Big Girls 1",
        "Big Girls 2",
        "Big Girls 3",
        "Big Girls 4",
        "Big Girls 5",
        "Women's 6",
        "Women's 7",
        "Women's 8",
        "Women's 9",
        "Women's 10",
        "Women's 11"]
      when "Boys Accessories"
        rvalue = []
      when "Girls Accessories"
        rvalue = []
      when "Baby, Toddler & Preschool Toys"
        rvalue = []
      when "Youth (Girls and Boys) Toys"
        rvalue = []
      when "Games & Puzzles"
        rvalue = []
      when "Books"
        rvalue = []
      when "Mommy Corner Clothing"
        rvalue = ["X-Small",
        "Small",
        "Medium",
        "Large",
        "X-Large",
        "1X",
        "2X",
        "3X",
        "4X"]
      when "Mommy Corner"
        rvalue = []
      when "Home School/Classroom Supplies"
        rvalue = []
      when "DVDs, Video Games & Electronics"
        rvalue = []
      when "Backpacks, Lunchboxes & Purses"
        rvalue = []
      when "Sporting Gear and Pool Supplies"
        rvalue = []
      when "Handmade and Boutique Items"
        rvalue = []
      when "Sport Clothing"
        rvalue = ["X-Small",
        "Small",
        "Medium",
        "Large",
        "X-Large"]
      when "Sporting Shoes"
        rvalue = ["Toddler 8",
        "Toddler 9",
        "Toddler 10",
        "Toddler 11",
        "Toddler 12",
        "Toddler 13",
        "Youth 1",
        "Youth 2",
        "Youth 3",
        "Youth 4",
        "Youth 5",
        "Youth 6",
        "Men's 7",
        "Men's 8",
        "Men's 9",
        "Men's 10",
        "Men's 11",
        "Men's 12",
        "Men's 13"]
      when "Baby Items"
        rvalue = []
      when "Baby Furniture"
        rvalue = []
      when "Baby Gear & Equipment"
        rvalue = []
      when "Baby Clothing Accessories"
        rvalue = []
      when "Bedding & Room Decor"
        rvalue = []
      when "Halloween Costumes"
        rvalue = ["Small",
        "Medium",
        "Large",
        "X-Large"]
      when "Party Supplies and Seasonal Accessories"
        rvalue = []
      when "No Category"
        rvalue = []
      else
        rvalue = ["Infant 0-3 months",
        "Infant 3-6 months",
        "Infant 6-9 months",
        "Infant 9-12 months",
        "Infant 12-18 months",
        "Infant 18-24 months",
        "Toddler 2T",
        "Toddler 3T",
        "Toddler 4T",
        "Toddler 5T",
        "Youth 4/5",
        "Youth 6-6x",
        "Youth 7/8",
        "Youth 9/10",
        "Youth 11/12",
        "Youth 14/16",
        "Junior X-Small (0-1)",
        "Junior Small (3/5)",
        "Junior Medium (7/9)",
        "Junior Large (11/13)",
        "Young Men's",
        "Young Men's Small",
        "Young Men's Medium",
        "Young Men's Large",
        "Young Men's  X Large",
        "X-Small",
        "Small",
        "Medium",
        "Large",
        "X-Large",
        "Infant 0-3",
        "Infant 4-6",
        "Infant 7",
        "Toddler 8",
        "Toddler 9",
        "Toddler 10",
        "Toddler 11",
        "Toddler 12",
        "Toddler 13",
        "Youth 1",
        "Youth 2",
        "Youth 3",
        "Youth 4+"]
      end
      rvalue << current_size unless current_size.nil? || rvalue.empty? || rvalue.include?(current_size)
      rvalue
    end   

    def backend_category_javascript
      rvalue = ""
      rvalue += "<script>"
      rvalue += "function updateCategory()"
      rvalue += "{"
      rvalue += "document.consignor_inventory_form.consignor_inventory_sub_category.options.length=0;"
      rvalue += "document.consignor_inventory_form.consignor_inventory_size.options.length=0;"
      rvalue += "category = document.consignor_inventory_form.consignor_inventory_category.value;"
      rvalue += "switch (category)"
      rvalue += "{"
      for category in self.category_array
        rvalue += "case '#{category[1]}':"
        sub_category_array = self.sub_category_array(category[0])
        if sub_category_array.empty?
          rvalue += "document.consignor_inventory_form.consignor_inventory_sub_category.options[0]=new Option('<No Sub Categories for this Category>', '', false, true);"
        else
          rvalue += "document.consignor_inventory_form.consignor_inventory_sub_category.options[0]=new Option('<Select a Sub Category>', '', false, true);"
          for sub_category in sub_category_array
            rvalue += "document.consignor_inventory_form.consignor_inventory_sub_category.options[document.consignor_inventory_form.consignor_inventory_sub_category.options.length]=new Option('#{self.escape_javascript(sub_category)}', '#{sub_category}', false, false);"
          end
        end
        size_array = self.size_array(category[0])
        if size_array.empty?
          rvalue += "document.consignor_inventory_form.consignor_inventory_size.options[0]=new Option('<No Sizes for this Category>', '', false, true);"
        else
          rvalue += "document.consignor_inventory_form.consignor_inventory_size.options[0]=new Option('<Select a Size>', '', false, true);"
          for size in size_array
            rvalue += "document.consignor_inventory_form.consignor_inventory_size.options[document.consignor_inventory_form.consignor_inventory_size.options.length]=new Option('#{self.escape_javascript(size)}', '#{(size)}', false, false);"
          end
        end
        rvalue += "break;"
      end
      rvalue += "}"
      rvalue += "}"
      rvalue += "function setSize(item)"
      rvalue += "{"
      rvalue += "document.consignor_inventory_form.consignor_inventory_size.options.length=0;"
      rvalue += "if (item.value == 'false')"
      rvalue += "{"
      size_array = self.size_array("")
      rvalue += "document.consignor_inventory_form.consignor_inventory_size.options[0]=new Option('<Select a Size>', '', false, true);"
      for size in size_array
        rvalue += "document.consignor_inventory_form.consignor_inventory_size.options[document.consignor_inventory_form.consignor_inventory_size.options.length]=new Option('#{self.escape_javascript(size)}', '#{(size)}', false, false);"
      end
      rvalue += "}"
      rvalue += "else"
      rvalue += "{"
      rvalue += "updateCategory()"
      rvalue += "}"
      rvalue += "}"
      rvalue += "</script>"
      return rvalue
    end

    def escape_javascript(string)
      string.gsub!("'", "\\\\'") if string.include?("'")
      string
    end

    def category_number_from_name(category_name)
      case category_name
      when "Boy's Clothing"
        "1"
      when "Girl's Clothing"
        "2"
      when "Maternity Clothing"
        "3"
      when "Boy's Shoes"
        "4"
      when "Girl's Shoes"
        "5"
      when "Boys Accessories"
        "6"
      when "Girls Accessories"
        "7"
      when "Baby, Toddler & Preschool Toys"
        "8"
      when "Youth (Girls and Boys) Toys"
        "9"
      when "Games & Puzzles"
        "10"
      when "Books"
        "11"
      when "Backpacks, Lunchboxes & Purses"
        "12"
      when "Sporting Gear and Pool Supplies"
        "13"
      when "Sport Clothing"
        "14"
      when "Sporting Shoes"
        "15"
      when "Baby Items"
        "16"
      when "Baby Clothing Accessories"
        "17"
      when "Bedding & Room Decor"
        "18"
      when "Halloween Costumes"
        "19"
      when "Handmade and Boutique Items"
        "22"
      when "DVDs, Video Games & Electronics"
        "23"
      when "Baby Furniture"
        "24"
      when "Baby Gear & Equipment"
        "25"
      when "Mommy Corner Clothing"
        "29"
      when "Mommy Corner"
        "26"
      when "Home School/Classroom Supplies"
        "27"
      when "Party Supplies and Seasonal Accessories"
        "28"
      end    
    end

    def category_name_from_number(category)
      case category
      when "1"
          "Boy's Clothing"
      when "2"
          "Girl's Clothing"
      when "3"
          "Maternity Clothing"
      when "4"
          "Boy's Shoes"
      when "5"
          "Girl's Shoes"
      when "6"
          "Boys Accessories"
      when "7"
          "Girls Accessories"
      when "8"
          "Baby, Toddler & Preschool Toys"
      when "9"
          "Youth (Girls and Boys) Toys"
      when "10"
          "Games & Puzzles"
      when "11"
          "Books"
      when "12"
          "Backpacks, Lunchboxes & Purses"
      when "13"
          "Sporting Gear and Pool Supplies"
      when "14"
          "Sport Clothing"
      when "15"
          "Sporting Shoes"
      when "16"
          "Baby Items"
      when "17"
          "Baby Clothing Accessories"
      when "18"
          "Bedding & Room Decor"
      when "19"
          "Halloween Costumes"
      when "22"
          "Handmade and Boutique Items"
      when "23"
          "DVDs, Video Games & Electronics"
      when "24"
          "Baby Furniture"
      when "25"
          "Baby Gear & Equipment"        
      when "26"
          "Mommy Corner"
      when "27"
          "Home School/Classroom Supplies"
      when "28"
          "Party Supplies and Seasonal Accessories"
      when "29"
          "Mommy Corner Clothing"
      end
    end
  end  
  

  private
  
  def delete_site_assets
    begin
      if File.exists?(self.barcode_file_path)
        Delayed::Job.enqueue(
          KidsCloset::RemoveBarcode.new(self.id), 10, 5.minutes.from_now
        )
      end
    rescue

    end
  end
  
  def create_site_asset
    if !self.status && self.donate_date.nil?
      Delayed::Job.enqueue(
        KidsCloset::CreateBarcode.new(self.id), 0, 0
      )
    end
  end

  def create_duplicate_items
    if self.quantity.to_i > 1
      for duplicate_item in 2..quantity.to_i
        new_item = ConsignorInventory.new
        new_item.quantity = 1
        new_item.item_description = self.item_description
        new_item.size = self.size
        new_item.price = self.price
        new_item.last_day_discount = self.last_day_discount
        new_item.donate = self.donate
        new_item.profile_id = self.profile_id
        new_item.printed = false
        new_item.save
      end
    end
  end

  def validate_size
    size_changed?
  end

  def test_featured_item
    self.featured_item && !self.status && self.donate_date.nil?
  end

  def delete_featured_photos_if_not_featured
    unless featured_item
      for photo in featured_photos
        photo.destroy
      end
    end
  end

  def add_or_remove_from_franchise_sale_list
    if !status && (donate_date.nil? || donate_date == "") && bring_to_sale && featured_item
      for online_franchise in Franchise.franchises_with_online_sales
        franchise_assignment = item_franchise_relationships.find(:first, :conditions => ["franchise_id = ?", online_franchise])
        if profile.franchises_consigning.include?(online_franchise)
          if franchise_assignment.nil?
            franchise_assignment = ItemFranchiseRelationship.new
            franchise_assignment.consignor_inventory_id = id
            franchise_assignment.franchise_id = online_franchise
            franchise_assignment.save
          end
        else
          franchise_assignment.destroy unless franchise_assignment.nil?
        end
      end
    else
      item_franchise_relationships.destroy_all
    end
  end
end
