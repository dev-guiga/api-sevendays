class UsersController < ApplicationController
  # skip_before_action :verify_authenticity_token
  def create
    @user = User.new(user_params)
    requested_status = params.dig(:user, :status)

    @user.status = (requested_status == "owner" || requested_status == :owner) ? "owner" : "user"
    if @user.save
      render :create, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private
  def user_params
    params.require(:user).permit(:first_name, :last_name, :username, :email_address, :password, :password_confirmation, :cpf, :address, :city, :state, :neighborhood, :birth_date)
  end
end
