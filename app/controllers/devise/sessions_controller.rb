module Devise
  class SessionsController < DeviseController
    respond_to :json

    prepend_before_action :require_no_authentication, only: :create
    prepend_before_action :allow_params_authentication!, only: :create

    def create
      self.resource = warden.authenticate(auth_options)

      if resource
        sign_in(resource_name, resource)
        render json: { message: "Signed in successfully" }, status: :ok
      else
        render json: { message: "Invalid email or password" }, status: :unauthorized
      end
    end

    def destroy
      sign_out(resource_name)
      head :no_content
    end

    protected

    def auth_options
      { scope: resource_name, recall: "#{controller_path}#create", locale: I18n.locale }
    end
  end
end
