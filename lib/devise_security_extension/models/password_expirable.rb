require 'devise_security_extension/hooks/password_expirable'

module Devise
  module Models
    # PasswordExpirable takes care of change password after
    module PasswordExpirable
      extend ActiveSupport::Concern

      included do
        before_save :update_password_changed
      end

      # is an password change required?
      def need_change_password?
        if self.class.expire_password_after.is_a?(Integer) || self.class.expire_password_after.is_a?(Float)
          password_changed_at.nil? || password_changed_at < self.class.expire_password_after.ago
        else
          false
        end
      end

      # set a fake datetime so a password change is needed and save the record
      def need_change_password!
        if self.class.expire_password_after.is_a?(Integer) || self.class.expire_password_after.is_a?(Float)
          need_change_password
          save(validate: false)
        end
      end

      # set a fake datetime so a password change is needed
      def need_change_password
        if self.class.expire_password_after.is_a?(Integer) || self.class.expire_password_after.is_a?(Float)
          self.password_changed_at = self.class.expire_password_after.ago
        end

        # is date not set it will set default to need set new password next login
        need_change_password if password_changed_at.nil?

        password_changed_at
      end

      private

      # is password changed then update password_cahanged_at
      def update_password_changed
        return unless (new_record? || encrypted_password_changed?) && !password_changed_at_changed?
        self.password_changed_at = Time.current
      end

      module ClassMethods
        ::Devise::Models.config(self, :expire_password_after)
      end
    end
  end
end
