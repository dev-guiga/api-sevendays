require 'rails_helper'

RSpec.describe User, type: :model do
  it "has a valid factory" do
    expect(create(:user)).to be_valid
  end

  it "is invalid without a username" do
    expect(build(:user, username: nil)).to be_invalid
  end

  it "is invalid without a email address" do
    expect(build(:user, email_address: nil)).to be_invalid
  end

  it "is invalid without a first name" do
    expect(build(:user, first_name: nil)).to be_invalid
  end

  it "is invalid without a last name" do
    expect(build(:user, last_name: nil)).to be_invalid
  end

  it "is invalid without a address" do
    expect(build(:user, address: nil)).to be_invalid
  end

  it "is invalid without a city" do
    expect(build(:user, city: nil)).to be_invalid
  end

  it "is invalid without a state" do
    expect(build(:user, state: nil)).to be_invalid
  end

  it "is invalid without a neighborhood" do
    expect(build(:user, neighborhood: nil)).to be_invalid
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
