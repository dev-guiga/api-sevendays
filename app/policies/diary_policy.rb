class DiaryPolicy < ApplicationPolicy
  def create?
    user&.owner?
  end

  def update?
    user&.owner?
  end

  def show?
    user&.owner? && record.user_id == user.id
  end
end
