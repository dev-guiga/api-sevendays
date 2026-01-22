require "rails_helper"

RSpec.describe SessionsController, type: :controller do
    render_views
  describe "routes" do
    it "routes POST /sign_in to sessions#create" do
      expect(post: "/sign_in").to route_to("sessions#create")
    end
    it "routes DELETE /sign_out to sessions#destroy" do
      expect(delete: "/sign_out").to route_to("sessions#destroy")
    end
  end
  describe "post #create" do
    context "with valid parameters" do
      let(:user) { create(:user, email: "test@example.com", password: "password123") }

      it "returns created status and user data" do
        post :create, params: {
          session: {
            email: user.email,
            password: "password123"
          }
        }, format: :json

        json = JSON.parse(response.body)
        expect(response.status).to eq(201)
        expect(json["success"]).to be true
        expect(json["user"]["email"]).to eq(user.email)
        expect(json["user"]["name"]).to eq(user.full_name)
        expect(session[:user_id]).to eq(user.id)
      end
    end

     context "with invalid email" do
      it "returns unauthorized" do
        post :create, params: {
          session: {
            email: "naoexiste@test.com",
            password: "password123"
          }
        }, format: :json

        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Invalid email or password")
        expect(response.status).to eq(401)
        expect(session[:user_id]).to be_nil
      end
    end

    context "with invalid password" do
      let(:user) { create(:user, email: "test@example.com", password: "password123") }
      it "returns unauthorized" do
        post :create, params: {
          session: {
            email: user.email,
            password: "senhaerrada"
          }
        }, format: :json

        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Invalid email or password")
        expect(response.status).to eq(401)
        expect(session[:user_id]).to be_nil
      end
    end
  end

  describe "delete #destroy" do
    let(:user) { create(:user, email: "test@example.com", password: "password123") }
    it "returns no content" do
      session[:user_id] = user.id
      delete :destroy, format: :json
      expect(response.status).to eq(204)
      expect(session[:user_id]).to be_nil
    end
  end
end
