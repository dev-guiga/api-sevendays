require "rails_helper"

RSpec.describe DiariesController, type: :controller do
  render_views
    let(:user) { create_user! }

  describe "routing" do
    it "routes GET /api/diaries to diaries#index" do
      expect(get: "/api/diaries").to route_to("diaries#index")
    end
  end

  describe "#index" do
    context "when authenticated" do
      before { sign_in(user) }
      let!(:diary) { create_diary!(user: user) }

      it "returns a list of diaries" do
        get :index, format: :json

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        expect(body["success"]).to eq(true)
        expect(body["diaries"].size).to eq(1)
        expect(body["diaries"].first["title"]).to eq(diary.title)
        expect(body["diaries"].first["description"]).to eq(diary.description)
      end
    end

    context "when unauthenticated" do
      it "returns unauthorized" do
        get :index, format: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
