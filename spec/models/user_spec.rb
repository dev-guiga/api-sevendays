require 'rails_helper'

RSpec.describe User, type: :model do
  it "has a valid factory" do
    expect(create(:user)).to be_valid
  end

  it "is invalid without a username" do
    expect(build(:user, username: nil)).to be_invalid
  end

  it "is invalid without a email address" do
    expect(build(:user, email: nil)).to be_invalid
  end

  it "is invalid without a first name" do
    expect(build(:user, first_name: nil)).to be_invalid
  end

  it "is invalid without a last name" do
    expect(build(:user, last_name: nil)).to be_invalid
  end

  it "is invalid without an address" do
    expect(build(:user, skip_address: true)).to be_invalid
  end

  it "is invalid without a birth date" do
    expect(build(:user, birth_date: nil)).to be_invalid
  end

  it "is invalid without a cpf" do
    expect(build(:user, cpf: nil)).to be_invalid
  end

  it "is invalid with a status different from owner, user or standard" do
       expect { build(:user, status: "invalid") }.to raise_error(ArgumentError)
  end
end
