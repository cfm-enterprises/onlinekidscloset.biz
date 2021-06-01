class ZipCode < ActiveRecord::Base
	def self.return_coordinates(zip)
		zip_code = find(:first, :conditions => ["ZipCode = ?", zip])
		return 0, 0 if zip_code.nil?
		return zip_code.Latitude, zip_code.Longitude
	end
end
