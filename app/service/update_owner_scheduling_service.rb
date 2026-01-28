class UpdateOwnerSchedulingService
  Result = Struct.new(:success, :scheduling, :user, :error, :status)

  def initialize(diary:, scheduling_id:, params:)
    @diary = diary
    @scheduling_id = scheduling_id
    @params = params
  end

  def call
    scheduling = diary.schedulings.find_by(id: scheduling_id)
    return error_result("Scheduling not found", :not_found) unless scheduling

    user = User.find_by(email: params[:user_email])
    return error_result("User not found", :not_found) unless user
    return error_result("User must be non-owner", :unprocessable_entity) if user.owner?

    unless scheduling.user_id == user.id
      return error_result("Scheduling does not belong to user", :unprocessable_entity)
    end

    if too_soon_to_edit?(scheduling)
      return error_result("Scheduling cannot be edited within 1 hour", :unprocessable_entity)
    end

    if scheduling.update(date: params[:date], time: params[:time])
      Result.new(true, scheduling, user, nil, nil)
    else
      Result.new(false, scheduling, user, scheduling.errors, :unprocessable_entity)
    end
  end

  private
  attr_reader :diary, :scheduling_id, :params

  def too_soon_to_edit?(scheduling)
    return false if scheduling.date.blank? || scheduling.time.blank?

    scheduled_at = Time.zone.local(
      scheduling.date.year,
      scheduling.date.month,
      scheduling.date.day,
      scheduling.time.hour,
      scheduling.time.min,
      scheduling.time.sec
    )

    scheduled_at < (Time.current + 1.hour).beginning_of_hour
  end

  def error_result(message, status)
    Result.new(false, nil, nil, message, status)
  end
end
