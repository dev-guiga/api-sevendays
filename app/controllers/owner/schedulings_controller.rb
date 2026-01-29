class Owner::SchedulingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_diary

  def create
    return if performed?

    authorize @diary, :schedule?

    result = CreateOwnerSchedulingService.new(diary: @diary, params: scheduling_params).call

    if result.success?
      @scheduling = result.payload[:scheduling]
      @user = result.payload[:user]

      render :create, status: :created

    elsif result.errors.is_a?(String)
      render_error(code: result.status.to_s, message: result.errors, status: result.status, details: nil)
    else
      render_validation_error(details: result.errors)
    end
  end

  def update
    return if performed?

    authorize @diary, :schedule?

    result = UpdateOwnerSchedulingService.new(
      diary: @diary,
      scheduling_id: params[:id],
      params: scheduling_params
    ).call

    if result.success?
      @scheduling = result.payload[:scheduling]
      @user = result.payload[:user]
      render :update, status: :ok
    elsif result.errors.is_a?(String)
      render_error(code: result.status.to_s, message: result.errors, status: result.status, details: nil)
    else
      render_validation_error(details: result.errors)
    end
  end

  private
  def scheduling_params
    params.require(:scheduling).permit(:user_email, :date, :time)
  end

  def set_diary
    @diary = current_user&.diary
    return if @diary

    render_error(code: "not_found", message: "Diary not found", status: :not_found, details: nil)
    return
  end
end
