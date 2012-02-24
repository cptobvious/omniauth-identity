require "digest/md5"

# PHASES

# 1. send_instructions_phase - Prompt for email address
# 2. reset_password_phase - Prompt for new password

module OmniAuth
  module Identity
    module Features
      module Resettable
        def send_instructions_path
          options[:send_instructions_path] || "#{path_prefix}/#{name}/sendinstructions"
        end
        
        def on_send_instructions_path?
          on_path?(send_instructions_path)
        end
        
        def reset_password_path
          options[:reset_password_path] || "#{path_prefix}/#{name}/resetpassword"
        end
        
        def on_reset_password_path?
          on_path?(reset_password_path)
        end
        
        def email_form
          OmniAuth::Form.build(
            :title => 'Reset Password',
            :url => send_instructions_path
          ) do |f|
            f.text_field 'Email address', 'email'
            f.button 'Reset password'
          end.to_response
        end
        
        def send_instructions_phase
          # for now it's fixed on the users email as identification
          # TODO make dynamic
          @identity = model.locate(request['email'])
          
          # TODO: security through obscurity?
          if @identity
            hash = Digest::MD5.hexdigest(@identity.password_digest)
            
            # TODO: send email with email and hash in url
            
            OmniAuth::Form.build(:title => 'Reset information sent') do |f|
              f.html <<-HTML
                <p>Please follow the instruction we sent to #{request['email']}.</p>
              HTML
              f.button ''
            end.to_response
          else
            OmniAuth::Form.build(
              :title => 'Problem encountered',
              :url => send_instructions_path
            ) do |f|
              f.html <<-HTML
                <p>There was a problem with your request.</p>
                <a href='#{send_instructions_path}'>Try again</a>
              HTML
              f.button ''
            end.to_response
          end
        end
        
        def new_password_form
          OmniAuth::Form.build(
            :title => 'Enter new password',
            :url => reset_password_path
          ) do |f|
            f.html <<-HTML
              <input type='hidden' name='hash' value="#{request['hash']}" />
              <input type='hidden' name='email' value="#{request['email']}" />
            HTML
            f.password_field 'New Password', 'password'
            f.password_field 'Confirm Password', 'password_confirmation'
          end.to_response
        end
        
        def reset_password_phase
          @identity = model.locate(request['email'])
          
          if @identity && Digest::MD5.hexdigest(@identity.password_digest) == request['hash'] && request['password'] == request['password_confirmation']
            @identity.password = request['password']
            @identity.save
            
            OmniAuth::Form.build(
              :title => 'Successfully resetted password',
              :url => reset_password_path
            ) do |f|
              f.html <<-HTML
                <p>You can now login with your new credentials.</p>
              HTML
              f.button ''
            end.to_response
          else
            OmniAuth::Form.build(:title => 'Invalid information') do |f|
              f.html <<-HTML
                <p>The information provided is invalid.</p>
              HTML
              f.button ''
            end.to_response
          end
        end
      end
    end
  end
end