class DiariesController < ApplicationController
  before_action :authenticate_user!

  def index
    return if performed?

    @diaries = Diary.all
    render :index, status: :ok
  end
end
