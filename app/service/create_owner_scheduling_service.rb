class CreateOwnerSchedulingService
  Result = Struct.new(:success, :scheduling, :user, :error, :status)

  def initialize(diary:, params:)
    @diary = diary
    @params = params
  end

  def call
    user = User.find_by(email: params[:user_email])
    return error_result("User not found", :not_found) unless user
    return error_result("User must be non-owner", :unprocessable_entity) if user.owner?

    scheduling_rule = diary.scheduling_rule
    return error_result("Scheduling rule not found", :unprocessable_entity) unless scheduling_rule

    now = Time.current

    diary.with_lock do
      scheduling = diary.schedulings.new(
        user: user,
        scheduling_rule: scheduling_rule,
        date: params[:date],
        time: params[:time],
        description: "scheduling created by owner",
        created_at: now,
        updated_at: now
      )

      if scheduling.save
        return Result.new(true, scheduling, user, nil, nil)
      end

      Result.new(false, scheduling, user, scheduling.errors, :unprocessable_entity)
    end
  end

  private
  attr_reader :diary, :params

  def error_result(message, status)
    Result.new(false, nil, nil, message, status)
  end
end
