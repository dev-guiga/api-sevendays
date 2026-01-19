require 'rails_helper'
RSpec.describe UsersController, type: :request do
  describe "POST /users" do
    context "with valid parameters" do
      let(:valid_attributes) {
        {
          first_name: "John",
          username: "john.doe",
          last_name: "Doe",
          email_address: "john.doe@example.com",
          password: "password",
          password_confirmation: "password",
          cpf: "12345678900",
          address: "123 Main St",
          status: "owner",
          city: "Anytown",
          state: "CA",
          neighborhood: "Downtown",
          birth_date: "1990-01-01"
        }
      }
      it "creates a new User" do
       user = User.create(valid_attributes)
       expect(user.first_name).to eq("John")
       expect(user.username).to eq("john.doe")
       expect(user.last_name).to eq("Doe")
       expect(user.email_address).to eq("john.doe@example.com")
       expect(user.password).to eq("password")
       expect(user.password_confirmation).to eq("password")
       expect(user.cpf).to eq("12345678900")
       expect(user.address).to eq("123 Main St")
       expect(user.status).to eq("owner")
       expect(user.city).to eq("Anytown")
       expect(user.state).to eq("CA")
       expect(user.neighborhood).to eq("Downtown")
       expect(user.birth_date).to eq(Date.parse("1990-01-01"))
      end
       describe "with invalid parameters" do
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
          }.to change(User, :count).by(0)
        end
      end

      describe "username already exists" do
        let(:existing_user) {
          User.create!(
          first_name: "Jane",
          username: "john.doe",  # mesmo username
          last_name: "Smith",
          email_address: "jane.smith@example.com",
          password: "password123",
          password_confirmation: "password123",
          cpf: "98765432100",
          address: "456 Oak St",
          status: "user",
          city: "Other City",
          state: "NY",
          neighborhood: "Uptown",
          birth_date: "1985-05-15"
        )
      }

        it "does not create a new User" do
          existing_user  # cria o usuário existente primeiro
          expect {
            post "/users", params: { user: valid_attributes }, as: :json
          }.not_to change(User, :count)
        end

        it "returns unprocessable entity status" do
          existing_user
          post "/users", params: { user: valid_attributes }, as: :json
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns validation errors" do
          existing_user
          post "/users", params: { user: valid_attributes }, as: :json
          json = JSON.parse(response.body)
          expect(json["username"]).to include("has already been taken")
        end
      end
    end
  end
end
