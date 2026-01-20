class SessionsController < ApplicationController
  def create
    @user = User.find_by(email_address: session_params[:email_address])
    if @user&.valid_password?(session_params[:password])
      session[:user_id] = @user.id
      render :create, status: :created
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  def destroy
    reset_session
    head :no_content
  end

  private
  def session_params
    params.require(:session).permit(:email_address, :password)
  end
end
