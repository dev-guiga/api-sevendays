require "rails_helper"

RSpec.describe SessionsController, type: :controller do
    render_views
  describe "routes" do
    it "routes POST /sign_in to sessions#create" do
      expect(post: "/sign_in").to route_to("sessions#create")
    end
  end
  describe "post #create" do
    context "with valid parameters" do
      let(:user) { create(:user, email_address: "test@example.com", password: "password123") }

      it "returns created status and user data" do
        post :create, params: {
          session: {
            email_address: user.email_address,
            password: "password123"
          }
        }, format: :json

        json = JSON.parse(response.body)
        expect(response.status).to eq(201)
        expect(json["success"]).to be true
        expect(json["user"]["email"]).to eq(user.email_address)
        expect(json["user"]["name"]).to eq(user.full_name)
      end
    end

     context "with invalid email" do
      it "returns unauthorized" do
        post :create, params: {
          session: {
            email_address: "naoexiste@test.com",
            password: "password123"
          }
        }, format: :json

        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Invalid email or password")
        expect(response.status).to eq(401)
      end
    end

    context "with invalid password" do
      let(:user) { create(:user, email_address: "test@example.com", password: "password123") }
      it "returns unauthorized" do
        post :create, params: {
          session: {
            email_address: user.email_address,
            password: "senhaerrada"
          }
        }, format: :json

        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Invalid email or password")
        expect(response.status).to eq(401)
      end
    end
  end
end
