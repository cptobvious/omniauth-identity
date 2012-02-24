require 'bcrypt'

module OmniAuth
  module Identity
    module Features
      module Resettable
        def reset_password_path
          options[:reset_password_path] || "#{path_prefix}/#{name}/resetpassword"
        end
      
        def on_reset_password_path?
          on_path?(reset_password_path)
        end
      
        def reset_password_phase
          # needed extra columns: reset_hash:string
          # use same bcrypt functionality as for the password but with different
          # parameters
        
          # IMPORTANT: once password is resetted, people can still use their old
          # password and after successful login, account will be resetted from
          # the reset.
        
          if request.get? # prompt for email address
            if request['hash']
              # get info from identity entry based on hash
            
              OmniAuth::Form.build(
                :title => 'Enter new password',
                :url => reset_password_path
              ) do |f|
                f.password_field 'New Password', 'password'
                f.password_field 'Confirm Password', 'password_confirmation'
              end.to_response
            else
              OmniAuth::Form.build(
                :title => 'Reset Password',
                :url => reset_password_path
              ) do |f|
                f.text_field 'Email address', 'email'
                f.button 'Reset password'
              end.to_response
            end
          elsif request.post?
            if request['password']
              # see if reset is valid and reset the password
            
            else
              # TODO: send email
              
              # create hash
              # mark identity entry as "resetted"
              
              # for now it's fixed on the users email as identification
              @identity = model.locate(request['email'])
              
              # TODO: security through obscurity?
              if @identity
                hash = BCrypt::Password.create(@identity.password_digest)
              
                @identity.reset_hash = hash
                @identity.save
              
                OmniAuth::Form.build(:title => 'Reset information sent') do |f|
                  reset_information = <<-HTML
                    <p>Please follow the instruction we sent to #{request['email']}.</p>
                  HTML
                  f.html reset_information
                  f.button ""
                end.to_response
              else
                OmniAuth::Form.build(:title => 'Problem encountered') do |f|
                  reset_information = <<-HTML
                    <p>There was a problem with your request.</p>
                  HTML
                  f.html reset_information
                  f.button ""
                end.to_response
              end
            end
          end
        
        
          # check for email parameter to send email
          # check for hash value to present password form
        end
      end
    end
  end
end