class DiaryPolicy < ApplicationPolicy
  def create?
    user&.owner?
  end
end
