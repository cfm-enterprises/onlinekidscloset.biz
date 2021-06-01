module KidsCloset
  module UserMixin

    def self.included(base)

      require 'digest/md5'

      base.class_eval do
        # Authenticates a user by their login name and unencrypted password.
        # For kids_closet, the original passwords used a different encryption scheme.
        # We will verify if the original password is valid, and if it is we will encrypt it using SHA and return the user
        # Returns the user or nil.
        def self.kids_authenticate(login, password)
          u = find :first, :conditions => ['lower(login) = lower(?)', login] # need to get the salt
          if u && u.crypted_password.length == 32  #This is a kids closet original first login
            if (u.kids_authenticated?(password) && !u.disabled? && u.valid_for_current_site?) #user is valid and matched the password
              u.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") 
              u.crypted_password = Digest::SHA1.hexdigest("--#{u.salt}--#{password}--")
              u.save                                  #save with sha1 encryption
              u                                       #return user
            else
              nil                                     #return nil, login failed
            end
          else
           (u && u.authenticated?(password) && !u.disabled? && u.valid_for_current_site?) ? u : nil
          end
        end      
        
        def kids_encrypt(password)
          Digest::MD5.hexdigest("#{Digest::MD5.hexdigest('dietcoke')}#{password}")
        end

        def kids_authenticated?(password)
          crypted_password == kids_encrypt(password)
        end

      end
    end
  end
end
