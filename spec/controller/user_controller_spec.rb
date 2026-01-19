require "rails_helper"

RSpec.describe UsersController, type: :request do
  describe "POST /users" do
    context "with valid parameters" do
      let(:valid_attributes) { FactoryBot.attributes_for(:user, :owner) }

      it "creates a new User" do
        expect {
          post "/users", params: { user: valid_attributes }, as: :json
        }.to change(User, :count).by(1)
      end

      it "returns created status" do
        post "/users", params: { user: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
      end

      it "creates user with correct attributes" do
        post "/users", params: { user: valid_attributes }, as: :json
        user = User.last

        expect(user.first_name).to eq(valid_attributes[:first_name])
        expect(user.last_name).to eq(valid_attributes[:last_name])
        expect(user.username).to eq(valid_attributes[:username])
        expect(user.email_address).to eq(valid_attributes[:email_address])
        expect(user.status).to eq("owner")
        expect(user).to be_persisted
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) {
        {
          first_name: "",
          username: "",
          last_name: "",
          email_address: ""
        }
      }

      it "does not create a new User" do
        expect {
          post "/users", params: { user: invalid_attributes }, as: :json
        }.not_to change(User, :count)
      end

      it "returns unprocessable entity status" do
        post "/users", params: { user: invalid_attributes }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when username already exists" do
      let!(:existing_user) { create(:user, username: "duplicate_user") }
      let(:duplicate_attributes) {
        FactoryBot.attributes_for(:user, :owner, username: "duplicate_user")
      }

      it "does not create a new User" do
        expect {
          post "/users", params: { user: duplicate_attributes }, as: :json
        }.not_to change(User, :count)
      end

      it "returns unprocessable entity status" do
        post "/users", params: { user: duplicate_attributes }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns validation errors" do
        post "/users", params: { user: duplicate_attributes }, as: :json
        json = JSON.parse(response.body)
        expect(json["username"]).to include("has already been taken")
      end
    end
  end
end
