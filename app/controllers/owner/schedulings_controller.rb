class Owner::SchedulingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_diary

  def create
    return if performed?

    authorize @diary, :schedule?

    result = CreateOwnerSchedulingService.new(diary: @diary, params: scheduling_params).call

    if result.success
      @scheduling = result.scheduling
      @user = result.user

      render :create, status: :created

    elsif result.error.is_a?(String)
      render json: { error: result.error }, status: result.status
    else
      render json: { errors: result.error }, status: result.status
    end
  end

  private
  def scheduling_params
    params.require(:scheduling).permit(:user_email, :date, :time)
  end

  def set_diary
    @diary = current_user&.diary
    return if @diary

    render json: { error: "Diary not found" }, status: :not_found
  end
end
