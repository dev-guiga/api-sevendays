class UpdateOwnerSchedulingRuleService
  def initialize(diary:, params:)
    @diary = diary
    @params = params
  end

  def call
    scheduling_rule = diary.scheduling_rule
    return error_result("Scheduling rule not found", :not_found) unless scheduling_rule

    diary.with_lock do
      scheduling_rule.reload
      draft_rule = build_draft_rule(scheduling_rule)

      unless draft_rule.valid?
        return validation_error_result(scheduling_rule, draft_rule.errors)
      end

      conflict_ids = conflicting_scheduling_ids(draft_rule)
      if conflict_ids.any?
        draft_rule.errors.add(:base, "conflicts with existing schedulings")
        draft_rule.errors.add(:base, "conflicting scheduling ids: #{conflict_ids.join(', ')}")
        return validation_error_result(scheduling_rule, draft_rule.errors)
      end

      if scheduling_rule.update(params)
        return ServiceResult.new(
          success: true,
          payload: { scheduling_rule: scheduling_rule }
        )
      end

      ServiceResult.new(
        success: false,
        payload: { scheduling_rule: scheduling_rule },
        errors: { scheduling_rule: scheduling_rule.errors },
        status: :unprocessable_entity
      )
    end
  end

  private
  attr_reader :diary, :params

  def build_draft_rule(scheduling_rule)
    draft_rule = scheduling_rule.dup
    draft_rule.assign_attributes(params)
    draft_rule.user_id = scheduling_rule.user_id
    draft_rule.diary_id = scheduling_rule.diary_id
    draft_rule
  end

  def conflicting_scheduling_ids(rule)
    diary.schedulings.where.not(status: "cancelled").find_each.filter_map do |scheduling|
      next unless conflicts_with_rule?(scheduling, rule)

      scheduling.id
    end
  end

  def conflicts_with_rule?(scheduling, rule)
    return false if scheduling.date.blank? || scheduling.time.blank?
    return false if scheduling.session_duration_minutes.blank?

    if rule.start_date && scheduling.date < rule.start_date
      return true
    end

    if rule.end_date && scheduling.date > rule.end_date
      return true
    end

    if rule.week_days.present? && !rule.week_days.include?(scheduling.date.wday)
      return true
    end

    return false if rule.start_time.blank? || rule.end_time.blank?

    start_seconds = rule.start_time.seconds_since_midnight
    end_seconds = rule.end_time.seconds_since_midnight
    time_seconds = scheduling.time.seconds_since_midnight
    duration_seconds = scheduling.session_duration_minutes.minutes

    return true if time_seconds < start_seconds
    return true if time_seconds + duration_seconds > end_seconds
    return false if duration_seconds <= 0

    offset_seconds = time_seconds - start_seconds
    (offset_seconds % duration_seconds).nonzero?
  end

  def validation_error_result(scheduling_rule, errors)
    ServiceResult.new(
      success: false,
      payload: { scheduling_rule: scheduling_rule },
      errors: { scheduling_rule: errors },
      status: :unprocessable_entity
    )
  end

  def error_result(message, status)
    ServiceResult.new(success: false, errors: message, status: status)
  end
end
