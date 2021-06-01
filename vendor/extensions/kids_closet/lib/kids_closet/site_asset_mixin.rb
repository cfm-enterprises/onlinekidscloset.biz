module KidsCloset
  module SiteAssetMixin

    def self.included(base)
      base.class_eval do
        has_many :sales, :dependent => :nullify
        has_many :franchise_photo, :dependent => :destroy
        has_one :transaction_import, :dependent => :nullify
        has_many :franchise_files, :dependent => :destroy
        has_one :rewards_import, :dependent => :destroy
        has_many :business_partners, :dependent => :nullify
                
        validates_format_of :asset_file_name, :with => /^[^ ]+$/, :message => " - Invalid File Name.  Please remove all spaces and re-upload the file."

      end
    end

  end
end
