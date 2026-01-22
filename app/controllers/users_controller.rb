class UsersController < ApplicationController
  # skip_before_action :verify_authenticity_token
  def create
    @user = User.new(user_params)
    if @user.save
      render :create, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private
  def user_params
    params.require(:user).permit(:first_name, :last_name, :username, :email, :password, :password_confirmation, :cpf, :address, :city, :state, :neighborhood, :birth_date, :status)
  end
end
