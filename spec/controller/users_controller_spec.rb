require "rails_helper"

RSpec.describe UsersController, type: :controller do
  # Routing specs
  describe "routing" do
    it "routes POST /sign_up to users#create" do
      expect(post: "/sign_up").to route_to("users#create")
    end
  end
  describe "POST #create" do
    context "with valid parameters" do
      let(:valid_attributes) { attributes_for(:user, :owner) }

      it "creates a new User" do
        expect {
          post :create, params: { user: valid_attributes }, format: :json
        }.to change(User, :count).by(1)
      end

      it "returns created status" do
        post :create, params: { user: valid_attributes }, format: :json
        expect(response).to have_http_status(:created)
      end

      it "creates user with correct attributes in database" do
        post :create, params: { user: valid_attributes }, format: :json
        user = User.last

        expect(user.first_name).to eq(valid_attributes[:first_name])
        expect(user.username).to eq(valid_attributes[:username])
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
          post :create, params: { user: invalid_attributes }, format: :json
        }.not_to change(User, :count)
      end

      it "returns unprocessable entity status" do
        post :create, params: { user: invalid_attributes }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns validation errors as JSON" do
        post :create, params: { user: invalid_attributes }, format: :json
        json = JSON.parse(response.body)

        expect(json).to have_key("first_name")
        expect(json).to have_key("username")
        expect(json).to have_key("email_address")
      end
    end

    context "when username already exists" do
      let!(:existing_user) { create(:user, username: "duplicate_user") }
      let(:duplicate_attributes) {
        attributes_for(:user, :owner, username: "duplicate_user")
      }

      it "does not create a new User" do
        expect {
          post :create, params: { user: duplicate_attributes }, format: :json
        }.not_to change(User, :count)
      end

      it "returns unprocessable entity status" do
        post :create, params: { user: duplicate_attributes }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns validation errors" do
        post :create, params: { user: duplicate_attributes }, format: :json
        json = JSON.parse(response.body)
        expect(json["username"]).to include("has already been taken")
      end
    end

    context "when email already exists" do
      let!(:existing_user) { create(:user, email_address: "duplicate@example.com") }
      let(:duplicate_attributes) {
        attributes_for(:user, :owner, email_address: "duplicate@example.com")
      }

      it "does not create a new User" do
        expect {
          post :create, params: { user: duplicate_attributes }, format: :json
        }.not_to change(User, :count)
      end

      it "returns validation errors for email" do
        post :create, params: { user: duplicate_attributes }, format: :json
        json = JSON.parse(response.body)
        expect(json["email_address"]).to include("has already been taken")
      end
    end

    context "when CPF already exists" do
      let!(:existing_user) { create(:user, cpf: "12345678900") }
      let(:duplicate_attributes) {
        attributes_for(:user, :owner, cpf: "12345678900")
      }

      it "does not create a new User" do
        expect {
          post :create, params: { user: duplicate_attributes }, format: :json
        }.not_to change(User, :count)
      end

      it "returns validation errors for CPF" do
        post :create, params: { user: duplicate_attributes }, format: :json
        json = JSON.parse(response.body)
        expect(json["cpf"]).to include("has already been taken")
      end
    end
  end
end
