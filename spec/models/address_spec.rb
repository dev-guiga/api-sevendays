require 'rails_helper'

RSpec.describe Address, type: :model do
  it "has a valid factory" do
    expect(build(:address)).to be_valid
  end

  it "is invalid without a user" do
    expect(build(:address, user: nil)).to be_invalid
  end

  it "is invalid without an address" do
    expect(build(:address, address: nil)).to be_invalid
  end

  it "is invalid without a city" do
    expect(build(:address, city: nil)).to be_invalid
  end

  it "is invalid without a state" do
    expect(build(:address, state: nil)).to be_invalid
  end

  it "is invalid without a neighborhood" do
    expect(build(:address, neighborhood: nil)).to be_invalid
  end
end
