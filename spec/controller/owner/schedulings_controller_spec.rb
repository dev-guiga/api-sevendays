require "rails_helper"

RSpec.describe Owner::SchedulingsController, type: :controller do
  render_views

  let(:owner) { create_user!(status: "owner") }
  let(:user) { create_user!(status: "user", email: "guilherme@example.com") }
  let(:diary) { create_diary!(user: owner) }
  let(:scheduling_rule) { create_scheduling_rule!(user: owner, diary: diary) }
  let(:scheduled_at) { (Time.current + 1.hour).beginning_of_hour }
  let(:scheduling_params) {
    {
      scheduling: {
        user_email: user.email,
        date: scheduled_at.to_date.to_s,
        time: scheduled_at.strftime("%H:%M")
      }
    }
  }

  describe "routing" do
    it "routes POST /api/owner/diary/schedulings to owner/schedulings#create" do
      expect(post: "/api/owner/diary/schedulings").to route_to("owner/schedulings#create")
    end
  end

  describe "#create" do
    context "when authorized" do
      before do
        session[:user_id] = owner.id
        scheduling_rule
      end

      it "creates a scheduling for the user and returns data" do
        expect {
          post :create, params: scheduling_params, format: :json
        }.to change(Scheduling, :count).by(1)

        expect(response).to have_http_status(:created)
        body = response.parsed_body
        expect(body["success"]).to eq(true)
        expect(body["user_email"]).to eq(user.email)
        expect(body["date"]).to eq(scheduled_at.to_date.to_s)
        expect(body["time"]).to be_present

        created = Scheduling.last
        expect(created.user_id).to eq(user.id)
        expect(created.diary_id).to eq(diary.id)
        expect(created.scheduling_rule_id).to eq(scheduling_rule.id)
      end
    end

    context "when time is before the next hour" do
      let(:too_soon_at) { Time.current.beginning_of_hour }

      before do
        session[:user_id] = owner.id
        scheduling_rule
      end

      it "returns unprocessable entity" do
        post :create, params: { scheduling: scheduling_params[:scheduling].merge(date: too_soon_at.to_date.to_s, time: too_soon_at.strftime("%H:%M")) }, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when date is not allowed by scheduling rule" do
      let(:allowed_week_day) { Date.current.wday }
      let(:disallowed_date) { Date.current + 1.day }
      let(:scheduling_rule) {
        create_scheduling_rule!(
          user: owner,
          diary: diary,
          overrides: {
            week_days: [ allowed_week_day ],
            start_time: "09:00",
            end_time: "18:00",
            start_date: Date.current,
            end_date: Date.current + 7.days
          }
        )
      }

      before do
        session[:user_id] = owner.id
        scheduling_rule
      end

      it "returns unprocessable entity" do
        post :create,
             params: {
               scheduling: scheduling_params[:scheduling].merge(
                 date: disallowed_date.to_s,
                 time: "12:00"
               )
             },
             format: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when user is not found" do
      before do
        session[:user_id] = owner.id
        scheduling_rule
      end

      it "returns not found" do
        post :create, params: { scheduling: scheduling_params[:scheduling].merge(user_email: "missing@example.com") }, format: :json

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is owner" do
      before do
        session[:user_id] = owner.id
        scheduling_rule
      end

      it "returns unprocessable entity" do
        post :create, params: { scheduling: scheduling_params[:scheduling].merge(user_email: owner.email) }, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when current user is not owner" do
      let(:non_owner) { create_user!(status: "user") }
      let!(:non_owner_diary) { create_diary!(user: non_owner) }

      before { session[:user_id] = non_owner.id }

      it "returns forbidden" do
        post :create, params: scheduling_params, format: :json

        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when diary does not exist" do
      let(:owner_without_diary) { create_user!(status: "owner") }

      before { session[:user_id] = owner_without_diary.id }

      it "returns not found" do
        post :create, params: scheduling_params, format: :json

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when unauthenticated" do
      it "returns unauthorized" do
        post :create, params: scheduling_params, format: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
