require "rails_helper"

RSpec.describe Owner::DiariesController, type: :controller do
  render_views

  let(:owner) { create_user!(status: "owner") }
  let(:user) { create_user!(status: "user") }
  let(:diary_params) { { title: "My Diary", description: "A long enough description." } }
  let(:scheduling_rule_params) {
    {
      start_time: "09:00",
      end_time: "10:00",
      week_days: [ 1, 3, 5 ],
      start_date: Date.current,
      end_date: Date.current + 7.days
    }
  }

  describe "routing" do
    it "routes POST /api/owner/diaries to owner/diaries#create" do
      expect(post: "/api/owner/diaries").to route_to("owner/diaries#create")
    end
  end

  describe "#create" do
    context "when authorized" do
      before { session[:user_id] = owner.id }

      it "creates a diary and a scheduling rule" do
        expect {
          post :create, params: { diary: diary_params, scheduling_rules: scheduling_rule_params }, format: :json
        }.to change(Diary, :count).by(1).and change(SchedulingRule, :count).by(1)

        expect(response).to have_http_status(:created)
        body = response.parsed_body
        expect(body["success"]).to eq(true)
        expect(body.dig("diary", "title")).to eq(diary_params[:title])
        expect(body.dig("scheduling_rule", "week_days")).to eq(scheduling_rule_params[:week_days])

        created_diary = Diary.last
        expect(created_diary.user_id).to eq(owner.id)
        expect(created_diary.scheduling_rule.user_id).to eq(owner.id)
      end
    end

    context "when user is not owner" do
      before { session[:user_id] = user.id }

      it "returns forbidden" do
        expect {
          post :create, params: { diary: diary_params, scheduling_rules: scheduling_rule_params }, format: :json
        }.not_to change(Diary, :count)

        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when unauthenticated" do
      it "returns unauthorized" do
        post :create, params: { diary: diary_params, scheduling_rules: scheduling_rule_params }, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when invalid parameters" do
      before { session[:user_id] = owner.id }

      it "returns 422" do
        post :create, params: { diary: diary_params.merge(title: nil), scheduling_rules: scheduling_rule_params }, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        body = response.parsed_body
        expect(body["diary"]).to include("title")
      end
    end
  end
end
