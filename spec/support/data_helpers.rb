require "faker"

module DataHelpers
  def address_attributes(overrides = {})
    {
      address: Faker::Address.street_address,
      city: Faker::Address.city,
      state: Faker::Address.state_abbr,
      neighborhood: Faker::Address.community
    }.merge(overrides)
  end

  def user_attributes(overrides = {}, address_overrides = {})
    {
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      username: Faker::Internet.unique.username(specifier: 6),
      email: Faker::Internet.unique.email,
      password: "password123",
      password_confirmation: "password123",
      cpf: Faker::Number.unique.number(digits: 11).to_s,
      birth_date: Faker::Date.birthday(min_age: 18, max_age: 65),
      status: "user",
      address_attributes: address_attributes(address_overrides)
    }.merge(overrides)
  end

  def create_user!(overrides = {}, address_overrides = {})
    User.create!(user_attributes(overrides, address_overrides))
  end

  def diary_attributes(user: create_user!, overrides: {})
    {
      user: user,
      title: Faker::Book.title,
      description: Faker::Lorem.characters(number: 30)
    }.merge(overrides)
  end

  def create_diary!(user: create_user!, overrides: {})
    Diary.create!(diary_attributes(user: user, overrides: overrides))
  end

  def scheduling_rule_attributes(user:, diary:, overrides: {})
    {
      user: user,
      diary: diary,
      start_time: "09:00",
      end_time: "10:00",
      week_days: [ 1, 3, 5 ],
      start_date: Date.current,
      end_date: Date.current + 7.days
    }.merge(overrides)
  end

  def create_scheduling_rule!(user: create_user!, diary: create_diary!(user: user), overrides: {})
    SchedulingRule.create!(scheduling_rule_attributes(user: user, diary: diary, overrides: overrides))
  end

  def scheduling_attributes(user: create_user!, diary: create_diary!(user: user), rule: create_scheduling_rule!(user: user, diary: diary), overrides: {})
    {
      diary: diary,
      scheduling_rule: rule,
      date: Date.current,
      time: "09:30",
      description: Faker::Lorem.characters(number: 30),
      status: "pending",
      created_at: Time.current,
      updated_at: Time.current
    }.merge(overrides)
  end

  def build_user(overrides = {}, address_overrides = {})
    User.new(user_attributes(overrides, address_overrides))
  end

  def build_diary(overrides = {})
    attrs = diary_attributes(**extract_diary_params(overrides))
    Diary.new(attrs)
  end

  def build_scheduling_rule(overrides = {})
    attrs = scheduling_rule_attributes(**extract_rule_params(overrides))
    SchedulingRule.new(attrs)
  end

  def build_scheduling(overrides = {})
    attrs = scheduling_attributes(**extract_sched_params(overrides))
    Scheduling.new(attrs)
  end

  private

  # Helpers to unpack optional keys without mutating caller hashes
  def extract_diary_params(overrides)
    user = overrides.key?(:user) ? overrides[:user] : create_user!
    { user: user, overrides: overrides.except(:user) }
  end

  def extract_rule_params(overrides)
    user_present = overrides.key?(:user)
    user = user_present ? overrides[:user] : create_user!

    diary =
      if overrides.key?(:diary)
        overrides[:diary]
      elsif user
        create_diary!(user: user)
      else
        nil
      end

    { user: user, diary: diary, overrides: overrides.except(:user, :diary) }
  end

  def extract_sched_params(overrides)
    user = overrides.delete(:user) || create_user!
    diary = overrides.delete(:diary) || create_diary!(user: user)
    rule = overrides.delete(:scheduling_rule) || create_scheduling_rule!(user: user, diary: diary)
    { user: user, diary: diary, rule: rule, overrides: overrides }
  end
end
