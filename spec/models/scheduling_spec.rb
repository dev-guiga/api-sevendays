require 'rails_helper'

RSpec.describe Scheduling, type: :model do
  def build_scheduling(overrides = {})
    user = create_user!
    diary = create_diary!(user: user)
    rule = create_scheduling_rule!(user: user, diary: diary)

    Scheduling.new(
      {
        user: user,
        diary: diary,
        scheduling_rule: rule,
        date: Date.current,
        time: "09:30",
        description: Faker::Lorem.characters(number: 20),
        status: "pending",
        created_at: Time.current,
        updated_at: Time.current
      }.merge(overrides)
    )
  end

  describe "validations" do
    it "is valid with required attributes" do
      expect(build_scheduling).to be_valid
    end

    it "is invalid without a diary" do
      expect(build_scheduling(diary: nil)).to be_invalid
    end

    it "is invalid without a scheduling_rule" do
      expect(build_scheduling(scheduling_rule: nil)).to be_invalid
    end

    it "is invalid without a user" do
      expect(build_scheduling(user: nil)).to be_invalid
    end

    it "is invalid without a date" do
      expect(build_scheduling(date: nil)).to be_invalid
    end

    it "is invalid without a time" do
      expect(build_scheduling(time: nil)).to be_invalid
    end

    it "is invalid without a description" do
      expect(build_scheduling(description: nil)).to be_invalid
    end

    it "is invalid with a short description" do
      expect(build_scheduling(description: "short")).to be_invalid
    end

    it "is invalid with an unsupported status" do
      expect(build_scheduling(status: "invalid")).to be_invalid
    end
  end
end
