class RegistrationsController < Devise::RegistrationsController
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.respond_to?(:unconfirmed_email) ? resource.unconfirmed_email : nil

    resource_updated = update_resource(resource, account_update_params)
    yield resource if block_given?
    if resource_updated
      set_flash_message_for_update(resource, prev_unconfirmed_email)
      bypass_sign_in resource, scope: resource_name if sign_in_after_change_password?

      respond_with resource, location: after_update_path_for(resource)
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  protected

  def update_resource(resource, params)
    # Only require current_password if password is being changed
    if params[:password].present?
      resource.update_with_password(params)
    else
      # Remove password fields and current_password requirement
      params.delete(:password)
      params.delete(:password_confirmation)
      params.delete(:current_password)
      resource.update_without_password(params)
    end
  end

  def account_update_params
    params.require(:user).permit(:name, :email, :phone, :location, :avatar, :password, :password_confirmation, :current_password)
  end
end
