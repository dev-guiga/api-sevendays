class UsersController < ApplicationController
  # skip_before_action :verify_authenticity_token
  def create
    @user = User.new(user_params_with_address)
    if @user.save
      render :create, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private
  def user_params_with_address
    permitted = params.require(:user).permit(
      :first_name,
      :last_name,
      :username,
      :email,
      :password,
      :password_confirmation,
      :cpf,
      :birth_date,
      :status,
      address_attributes: [:address, :city, :state, :neighborhood]
    )

    permitted[:address_attributes] ||= address_params_from_root
    permitted
  end

  def address_params_from_root
    params.require(:user)
          .permit(:address, :city, :state, :neighborhood)
          .to_h
          .compact_blank
          .presence
  end
end
