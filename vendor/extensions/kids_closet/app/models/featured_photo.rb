require 'ftools'
class FeaturedPhoto < ActiveRecord::Base

  before_save :ensure_display_name

  attr_accessible :asset_file_name, :asset, :tag_list, :display_name, :caption, :consignor_inventory_id

  has_attached_file :asset,
                    :url => "/:attachment/:current_site_id/:style/:basename.:extension",
                    :path => ":rails_root/public/:attachment/:current_site_id/:style/:basename.:extension",
                    :styles => { :original => "x800", :thumb => "x64" },
                    :whiny => false

  validates_attachment_presence :asset

  belongs_to :consignor_inventory

  def validate
  	errors.add(:asset, "Can't have more than five images per item") if new_record? && consignor_inventory.featured_photos.count >= 5
  end

  def image_type?
    Bionic::ImageContentTypes.include?(asset_content_type)
  end

  def url(style = :original)
    self.asset.url(style)
  end

  def file_path(style = "original")
    "#{RAILS_ROOT}/public/assets/#{self.site_id}/#{style}/#{self.asset_file_name}"
  end

  def file_name
    asset_file_name
  end
  
  def name
    display_name
  end

  def rotation_class
    case rotation
    when 0
      return "rotate0"
    when 90
      return "rotate90"
    when 180
      return "rotate180"
    when 270
      return "rotate270"
    else
      return "rotate0"
    end
  end

  def rotate_clockwise
    if rotation.nil?
      self.rotation = 90
    else
      self.rotation += 90
      self.rotation = 0 if rotation == 360
    end
  end

  def rotate_counter_clockwise
    if rotation.nil?
      self.rotation = 270
    else
      self.rotation -= 90
      self.rotation = 270 if rotation == -90
    end
  end

  class << self
    def rename_featured_file(photo_id)
      photo = FeaturedPhoto.find(photo_id)
      old_file_name = photo.asset_file_name
      unless old_file_name.nil? || old_file_name[0, 9] == "featured_"
        extension_begins_at = old_file_name.index('.', -6)
        old_file_path = "#{RAILS_ROOT}/public/assets/#{Site.current_site_id}/original/#{old_file_name}"
        old_thumb_path = "#{RAILS_ROOT}/public/assets/#{Site.current_site_id}/thumb/#{old_file_name}"
        new_file_name = "featured_#{photo.id}#{old_file_name[extension_begins_at, 10]}"
        new_file_path = "#{RAILS_ROOT}/public/assets/#{Site.current_site_id}/original/#{new_file_name}"
        new_thumb_path = "#{RAILS_ROOT}/public/assets/#{Site.current_site_id}/thumb/#{new_file_name}"
        if File.exists?(old_file_path)
          File.move(old_file_path, new_file_path)
        end
        if File.exists?(old_thumb_path)
          File.move(old_thumb_path, new_thumb_path)
        end
        photo.asset_file_name = new_file_name
        photo.save_with_validation(false)
      end
    end
  end

  private

  def rename_file_name
#    FeaturedPhoto.rename_featured_file(self.id)
  end

  def ensure_display_name
    if self.display_name.nil? || self.display_name.blank?
      self.display_name = self.file_name
    end
  end

end
