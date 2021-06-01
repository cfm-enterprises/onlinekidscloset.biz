module KidsCloset
  module ProfileSearchMixin

    def self.included(base)

      base.class_eval do
        remove_method :profiles

			  def profiles
			    Profile.paginate(
			      :conditions => conditions,
			      :per_page => per_page,
			      :order => order,
			      :page => page,
			      :joins => (user_group_search? ? [:user => :user_groups] : " LEFT JOIN users ON users.profile_id = profiles.id")
			    )
			  end

      end
    end


  end
end
