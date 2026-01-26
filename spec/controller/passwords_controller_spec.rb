require "rails_helper"

RSpec.describe Devise::PasswordsController, type: :routing do
  it "roteia POST /api/users/password para devise/passwords#create" do
    expect(post: "/api/users/password").to route_to("devise/passwords#create")
  end

  it "roteia PUT /api/users/password para devise/passwords#update" do
    expect(put: "/api/users/password").to route_to("devise/passwords#update")
  end

  it "roteia PATCH /api/users/password para devise/passwords#update" do
    expect(patch: "/api/users/password").to route_to("devise/passwords#update")
  end
end
