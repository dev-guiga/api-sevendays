class Owner::SchedulingRulesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_diary

  def update
    return if performed?

    authorize @diary, :schedule?

    result = UpdateOwnerSchedulingRuleService.new(diary: @diary, params: scheduling_rule_params).call

    if result.success?
      @scheduling_rule = result.payload[:scheduling_rule]
      render :update, status: :ok
    elsif result.errors.is_a?(String)
      render_error(code: result.status.to_s, message: result.errors, status: result.status, details: nil)
    else
      render_validation_error(details: result.errors)
    end
  end

  private
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

  def set_diary
    @diary = current_user&.diary
    return if @diary

    render_error(code: "not_found", message: "Diary not found", status: :not_found, details: nil)
    return
  end
end
