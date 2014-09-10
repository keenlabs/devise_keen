require 'devise_keen/hooks/signin'
require 'devise_keen/hooks/signout'

module Devise
  module Models
    module KeenTrackable
      def keen_record_signin
        self.publish_action("signin", {sign_in_time: self.current_sign_in_at})
      end

      def keen_record_signout
        self.publish_action("signout", {sign_out_time: Time.now.iso8601})
      end

      protected
      def publish_action(action, params)
        raise new Exception("Must define keen_project_id.") if self.class.keen_project_id.nil?
        raise new Exception("Must define keen_write_key.") if self.class.keen_write_key.nil?

        keen = Keen::Client.new(project_id: self.class.keen_project_id,
                                write_key: self.class.keen_write_key)

        event_params = {
          user: {
            id: self.id,
            email: self.email
          },
          action: "#{action}"
        }

        event_params.merge!(params)

        keen.publish(self.class.keen_collection, event_params)
      end
    end

    Devise::Models.config(self, :keen_project_id)
    Devise::Models.config(self, :keen_write_key)
    Devise::Models.config(self, :keen_collection)
  end
end
