class Scheduling < ApplicationRecord
  belongs_to :diary, inverse_of: :schedulings
  belongs_to :scheduling_rule, inverse_of: :schedulings
  belongs_to :user, inverse_of: :schedulings

  validates :diary_id, presence: true
  validates :scheduling_rule_id, presence: true
  validates :user_id, presence: true
  validates :date, presence: true
  validates :time, presence: true
  validates :description, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :status, presence: true, inclusion: { in: %w[pending completed cancelled] }
  validates :created_at, presence: true
  validates :updated_at, presence: true
end
