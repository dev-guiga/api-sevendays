class Owner::DiariesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_diary, except: [ :create ]

  def create
    authorize Diary

    result = CreateDiariesServices.new(
      current_user: current_user,
      diary_params: diary_params,
      scheduling_rule_params: scheduling_rule_params
    ).call

    if result.success
      @diary = result.diary
      @scheduling_rule = result.scheduling_rule
      render :create, status: :created
    else
      render json: { diary: result.diary.errors, scheduling_rule: result.scheduling_rule.errors }, status: :unprocessable_entity
    end
  end

  def update
    authorize @diary

    if @diary.update(diary_params)
      render :update, status: :ok
    else
      render json: { diary: @diary.errors }, status: :unprocessable_entity
    end
  end

  def show
    authorize @diary
    @schedulings = @diary.schedulings.includes(scheduling_rule: :user)
    render :show, status: :ok
  end

  private
  def set_diary
    @diary = if params[:id].present?
      Diary.find_by(id: params[:id])
    else
      current_user&.diary
    end

    unless @diary
      render json: { error: "Diary not found" }, status: :not_found
    end
  end

  def diary_params
    params.require(:diary).permit(:title, :description)
  end

  def scheduling_rule_params
    params.require(:scheduling_rules).permit(
      :start_time,
      :end_time,
      :start_date,
      :end_date,
      :session_duration_minutes,
      week_days: []
    )
  end
end
