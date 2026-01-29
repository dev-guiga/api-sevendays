class CreateUsersServices
  def initialize(user_params)
    @user_params = user_params
  end
  def call
    User.create(user_params_with_address)
  end

  private
  attr_reader :user_params

  def user_params_with_address
    permitted = user_params.permit(
      :first_name,
      :last_name,
      :username,
      :email,
      :password,
      :password_confirmation,
      :cpf,
      :birth_date,
      :status,
      address_attributes: [ :address, :city, :state, :neighborhood ]
    )

    permitted[:address_attributes] ||= address_params_from_root
    permitted
  end

  def address_params_from_root
    user_params.permit(:address, :city, :state, :neighborhood).to_h.compact_blank.presence
  end
end
