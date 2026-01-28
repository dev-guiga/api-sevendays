class CreateDiariesServices
  Result = Struct.new(:diary, :scheduling_rule, :success)

  def initialize(current_user:, diary_params:, scheduling_rule_params:)
    @current_user = current_user
    @diary_params = diary_params
    @scheduling_rule_params = scheduling_rule_params
  end

  def call
    diary = @current_user.build_diary(diary_params)
    scheduling_rule = diary.build_scheduling_rule(scheduling_rule_params.merge(user: @current_user))

    success = diary.valid? && scheduling_rule.valid?

    if success
      Diary.transaction do
        diary.save!
        scheduling_rule.save!
      end
    end

    Result.new(diary, scheduling_rule, success)
  end

  private
  attr_reader :current_user, :diary_params, :scheduling_rule_params
end
