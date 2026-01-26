require 'rails_helper'

RSpec.describe SchedulingRule, type: :model do
  def build_rule(overrides = {})
    user = overrides.key?(:user) ? overrides.delete(:user) : create_user!
    diary =
      if overrides.key?(:diary)
        overrides.delete(:diary)
      elsif user
        create_diary!(user: user)
      else
        nil
      end

    SchedulingRule.new(
      {
        user: user,
        diary: diary,
        start_time: "09:00",
        end_time: "10:00",
        week_days: [ 1, 3, 5 ],
        start_date: Date.current,
        end_date: Date.current + 7.days
      }.merge(overrides)
    )
  end

  describe "validations" do
    it "is valid with required attributes" do
      expect(build_rule).to be_valid
    end

    it "is invalid without a user" do
      expect(build_rule(user: nil)).to be_invalid
    end

    it "is invalid without a diary" do
      expect(build_rule(diary: nil)).to be_invalid
    end

    it "is invalid without start_time" do
      expect(build_rule(start_time: nil)).to be_invalid
    end

    it "is invalid without end_time" do
      expect(build_rule(end_time: nil)).to be_invalid
    end

    it "is invalid without week_days" do
      expect(build_rule(week_days: nil)).to be_invalid
    end

    it "is invalid when end_date is before start_date" do
      rule = build_rule(start_date: Date.current, end_date: Date.yesterday)
      expect(rule).to be_invalid
      expect(rule.errors[:end_date]).to include("must be equal or after start_date")
    end
  end
end
