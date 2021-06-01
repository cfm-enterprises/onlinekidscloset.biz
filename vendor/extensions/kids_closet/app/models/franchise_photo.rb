require 'ftools'
class FranchisePhoto < ActiveRecord::Base
  before_save :rename_file_name, :ensure_display_name
  acts_as_audited :protect => false

  attr_accessible :asset_file_name, :asset, :tag_list, :display_name, :caption, :show_in_slider, :sort_order

  belongs_to :franchise
  belongs_to :site_asset
    
  acts_as_site_member

  has_attached_file :asset,
                    :url => "/:attachment/:current_site_id/:style/:basename.:extension",
                    :path => ":rails_root/public/:attachment/:current_site_id/:style/:basename.:extension",
                    :styles => { :thumb => "x310" },
                    :whiny => false

  validates_attachment_presence :asset

  validates_presence_of :franchise_id

  before_post_process :image_type?

  def validate
  	errors.add(:asset, " can only have 9 photos on the slider per franchise") if new_record? && show_in_slider && franchise.franchise_slider_photos.count >= 9
  	errors.add(:asset, " can only have 9 photos on the slider per franchise") if !new_record? && show_in_slider && franchise.franchise_slider_photos.count(:conditions => ["id != ?", id]) >= 9
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
private 

  def rename_file_name
    if self.asset_file_name_changed?
      old_file_name = self.asset_file_name_was
      old_file_path = "#{RAILS_ROOT}/public/assets/#{self.site_id}/original/#{old_file_name}"
      old_thumb_path = "#{RAILS_ROOT}/public/assets/#{self.site_id}/thumb/#{old_file_name}"
      if File.exists?(old_file_path)
        File.move(old_file_path, self.file_path)
      end
      if File.exists?(old_thumb_path)
        File.move(old_thumb_path, self.file_path("thumb"))
      end
    end
  end

  def ensure_display_name
    if self.display_name.nil? || self.display_name.blank?
      self.display_name = self.file_name
    end
  end
end
