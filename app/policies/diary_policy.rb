class DiaryPolicy < ApplicationPolicy
  def create?
    user&.owner?
  end

  def update?
    user&.owner?
  end
end
