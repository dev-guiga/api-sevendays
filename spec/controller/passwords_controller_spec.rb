require "rails_helper"

RSpec.describe PasswordsController, type: :routing do
  it "roteia POST /users/password para passwords#create" do
    expect(post: "/users/password").to route_to(controller: "passwords", action: "create")
  end

  it "roteia PUT /users/password para passwords#update" do
    expect(put: "/users/password").to route_to(controller: "passwords", action: "update")
  end
  it "roteia PATCH /users/password para passwords#update" do
    expect(patch: "/users/password").to route_to(controller: "passwords", action: "update")
  end
end
