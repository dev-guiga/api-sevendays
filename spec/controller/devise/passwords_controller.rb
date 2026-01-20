require 'rails_helper'
require "devise/passwords"

RSpec.describe Devise::PasswordsController, type: :controller do
 describe "routes" do
    it "routes POST /forgot_password to devise/passwords#create" do
      expect(post: "/forgot_password").to route_to("devise/passwords#create")
    end
  end

  describe "POST /forgot_password" do
    let!(:user) { create(:user, email_address: "test@example.com") }

    it "returns a success response" do
      post "/forgot_password", params: { user: { email_address: user.email_address } }, as: :json
      expect(response).to have_http_status(:ok).or have_http_status(:no_content).or have_http_status(:found)
    end
  end

  describe "PUT /reset_password" do
    let!(:user) { create(:user) }

    it "returns a success response" do
      token = user.send_reset_password_instructions
      put "/reset_password", params: {
        user: {
          reset_password_token: token,
          password: "newpass123",
          password_confirmation: "newpass123"
        }
      }, as: :json
      expect(response).to have_http_status(:ok).or have_http_status(:no_content).or have_http_status(:found)
    end
  end
end
