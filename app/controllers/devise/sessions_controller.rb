module Devise
class Devise::SessionsController < DeviseController
  # POST /resource/sign_in
  def create
    @user = User.find_by(email: params_user[:email])
    if @user.present? && @user.valid_password?(params_user[:password])
      sign_in(resource_name, @user)
      render json: { message: "Signed in successfully" }
    else
      render json: { message: "Invalid email or password" }, status: :unauthorized
    end
  end

  # DELETE /resource/sign_out
  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message! :notice, :signed_out if signed_out
    yield if block_given?
    render json: { message: "Signed out successfully" }
  end

  def auth_options
    { scope: resource_name, recall: "#{controller_path}#create", locale: I18n.locale }
  end
  private
  def params_user
    params.require(:user).permit(:email, :password)
  end
  def verify_signed_out_user
    if all_signed_out?
      render json: { message: "Already signed out" }, status: :unauthorized
    else
      render json: { message: "Signed out successfully" }
    end
  end

  def all_signed_out?
    users = Devise.mappings.keys.map { |s| warden.user(scope: s, run_callbacks: false) }

    users.all?(&:blank?)
    render json: { message: "All users are signed out" }, status: :unauthorized
  end
end
end
