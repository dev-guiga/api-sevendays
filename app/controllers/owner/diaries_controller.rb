class Owner::DiariesController < ApplicationController
  before_action :authenticate_user!, only: [ :create ]

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

  private
  def diary_params
    params.require(:diary).permit(:title, :description)
  end

  def scheduling_rule_params
    params.require(:scheduling_rules).permit(:start_time, :end_time, :start_date, :end_date, week_days: [])
  end
end
