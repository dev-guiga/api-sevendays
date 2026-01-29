class UsersController < ApplicationController
  # skip_before_action :verify_authenticity_token
  before_action :authenticate_user!, only: :me

  def create
    @user = User.new(user_params)
    requested_status = params.dig(:user, :status)

    @user.status = (requested_status == "owner" || requested_status == :owner) ? "owner" : "user"
    if @user.save
      render :create, status: :created
    else
      render_validation_error(details: @user.errors)
    end
  end

  def me
    @user = current_user
    render :me, status: :ok
  end

  private
  def user_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :username,
      :email,
      :password,
      :password_confirmation,
      :cpf,
      :birth_date,
      address_attributes: [ :address, :city, :state, :neighborhood ]
    )
  end
end
