require "rails_helper"

RSpec.describe DiaryPolicy, type: :policy do
  subject(:policy) { described_class }

  let(:owner) { create_user!(status: "owner") }
  let(:user) { create_user!(status: "user") }

  permissions :create? do
    it "allows owners" do
      expect(policy).to permit(owner, Diary)
    end

    it "denies non-owners" do
      expect(policy).not_to permit(user, Diary)
    end
  end
end
