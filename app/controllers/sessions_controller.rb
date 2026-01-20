class SessionsController < ApplicationController
  def create
    @user = User.find_by(email_address: session_params[:email_address])
    if @user&.authenticate(session_params[:password])
      render :create, status: :created
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  private
  def session_params
    params.require(:session).permit(:email_address, :password)
  end
end
