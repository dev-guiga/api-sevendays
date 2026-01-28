class Owner::DiariesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_diary, except: [ :create ]

  def create
    authorize Diary

    @diary = current_user.build_diary(diary_params)
    @scheduling_rule = @diary.build_scheduling_rule(scheduling_rule_params.merge(user: current_user))

    diary_valid = @diary.valid?
    rule_valid = @scheduling_rule.valid?

    if diary_valid && rule_valid
      Diary.transaction do
        @diary.save!
        @scheduling_rule.save!
      end
      render :create, status: :created
    else
      render json: { diary: @diary.errors, scheduling_rule: @scheduling_rule.errors }, status: :unprocessable_entity
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

  private
  def set_diary
    @diary = Diary.find_by(id: params[:id])

    unless @diary
      render json: { error: "Diary not found" }, status: :not_found
    end
  end

  def diary_params
    params.require(:diary).permit(:title, :description)
  end

  def scheduling_rule_params
    params.require(:scheduling_rules).permit(:start_time, :end_time, :start_date, :end_date, week_days: [])
  end
end
