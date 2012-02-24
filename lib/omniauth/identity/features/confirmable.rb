module OmniAuth
  module Identity
    module Features
      module Confirmable
        def confirm_identity_path
          options[:confirm_identity_path] || "#{path_prefix}/#{name}/confirm"
        end
        
        def on_confirm_identity_path?
          on_path?(confirm_identity_path)
        end
      end
    end
  end
end