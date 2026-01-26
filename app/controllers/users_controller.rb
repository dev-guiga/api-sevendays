class UsersController < ApplicationController
  # skip_before_action :verify_authenticity_token
  def create
    @user = CreateUsersServices.new(params.require(:user)).call
    if @user.save
      render :create, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end
end
